# deploy-silam

Pipeline for downloading SILAM pollen forecasts from FMI's THREDDS server, regridding to a Ukraine-focused grid, and generating pollen concentration maps.

## Project overview

Downloads 5-day pollen forecasts (alder, birch, grass, mugwort, olive, ragweed) from the Finnish Meteorological Institute (FMI) SILAM model, regrids them onto a Ukraine lat/lon grid, and produces PNG map images using GrADS.

## Entry point

```bash
bash solution.sh
```

This sources `environment` then runs `make_pictures.sh`, which calls `fetch_pollen_fc.sh` (download + regrid) then `draw_pollen.gs` (visualization).

## File structure

| File | Purpose |
|---|---|
| `solution.sh` | Entry point — sources env, runs pipeline |
| `environment` | All configuration: version, email, bbox, variables, paths |
| `fetch_pollen_fc.sh` | Downloads forecast from THREDDS, cleans attributes, regrids with CDO |
| `make_pictures.sh` | Orchestrates fetch + parallel GrADS rendering + logo overlay |
| `draw_pollen.gs` | GrADS script that renders pollen concentration maps per taxon |
| `UKR-rll.grid` | CDO grid descriptor for Ukraine (lon 22.05–40.55, lat 44.05–52.95, 0.1° resolution) |
| `Dockerfile` | Ubuntu 22.04 with wget, nco, cdo, grads |
| `scale.png` | Scale/logo overlay for output images |
| `fmi-logo-60x30a.png` | FMI logo |
| `cams` | CAMS high-resolution map data for GrADS borders |

## Version-dependent parameters (in `environment`)

The SILAM THREDDS data uses a **rotated pole grid**. When the SILAM model version changes, these parameters in `environment` must be updated:

- **`version`** — model version string (currently `v6_1`)
- **`varlist`** — comma-separated variable names (species codes like `_m22`, `_m20` can change between versions)
- **`subset`** — bounding box in **rotated coordinates** (NOT regular lat/lon)
- **`vertCoord`** — vertical level in meters (v6_1 lowest level is `12.5`, older versions used `1`)
- **`accept`** — netcdf format (`netcdf` or `netcdf4`, version-dependent)

### How to find correct parameters for a new version

1. Check the dataset metadata at:
   `https://thredds.silam.fmi.fi/thredds/ncss/grid/silam_europe_pollen_<VERSION>/runs/silam_europe_pollen_<VERSION>_RUN_<DATE>/dataset.html`

2. Get rotation parameters from OPeNDAP:
   `https://thredds.silam.fmi.fi/thredds/dodsC/silam_europe_pollen_<VERSION>/silam_europe_pollen_<VERSION>_best.ncd.das`
   Look for `grid_north_pole_latitude`, `grid_north_pole_longitude` (or equivalently `pole_lat`, `pole_lon`).

3. Convert Ukraine's regular lat/lon corners to rotated coordinates using the rotation formula (see below).

4. Check available variable names — species model numbers (e.g. `_m28` → `_m20` for olive) can change.

5. Check the lowest vertical level — inspect the `height` axis values.

### Rotated coordinate conversion

v6_1 rotation: south pole at (0°E, 30°S), i.e. `grid_north_pole_latitude=30`, `grid_north_pole_longitude=-180`.

```python
import math

def regular_to_rotated(lon, lat, sp_lon=0.0, sp_lat=-30.0):
    """Convert regular lon/lat to rotated (south pole convention)."""
    lon_r = math.radians(lon - sp_lon)
    lat_r = math.radians(lat)
    sp_lat_r = math.radians(-sp_lat)
    rlat = math.asin(
        -math.sin(lat_r) * math.sin(sp_lat_r) +
        math.cos(lat_r) * math.cos(sp_lat_r) * math.cos(lon_r)
    )
    rlon = math.atan2(
        -math.cos(lat_r) * math.sin(lon_r),
        -math.sin(lat_r) * math.cos(sp_lat_r) -
        math.cos(lat_r) * math.sin(sp_lat_r) * math.cos(lon_r)
    )
    return math.degrees(rlon) + 180.0, math.degrees(rlat)
```

Ukraine corners (22–41°E, 44–53°N) map to approximately rlon 12–30, rlat −2 to 15 in v6_1 rotated space. The current bbox `minx=11&maxx=31&miny=-3&maxy=15.9` includes ~1° margin for CDO bilinear interpolation.

## Testing

### Quick download test (no dependencies needed)

Test that the THREDDS query returns HTTP 200 with a single-timestep request:

```bash
source environment
run=$(date -u +"%FT00:00:00Z")
start=$(date -u +"%FT01:00:00Z")
URL="https://thredds.silam.fmi.fi/thredds/ncss/grid/silam_europe_pollen_${version}/runs/silam_europe_pollen_${version}_RUN_${run}"
wget --no-check-certificate "$URL?var=cnc_POLLEN_ALDER_m22${subset}&horizStride=1&time_start=${start}&time_end=${start}&timeStride=1&vertCoord=${vertCoord}&accept=${accept}" -O /tmp/test.nc
```

HTTP 200 + a valid .nc file = query parameters are correct.

### Full pipeline test (requires nco, cdo, grads)

```bash
bash solution.sh
```

Output goes to `output-UKR-pollen/<YYYYMMDD>/` (netcdf) and `output-UKR-pollen/webloads/` (PNG images).

### Docker

```bash
docker build -t silam .
docker run -it -v /var/data:/output-UKR-pollen/webloads silam bash solution.sh
```

## System dependencies

`wget`, `nco` (ncatted, ncks), `cdo`, `grads`, `imagemagick` (composite, convert). Install with:

```bash
sudo apt-get install -y --no-install-recommends wget nco cdo grads imagemagick
```

## Common issues

- **HTTP 400 from THREDDS**: Wrong variable names, bbox outside grid, invalid vertCoord, or unsupported accept format. Check parameters against dataset metadata.
- **Version upgrade breaks download**: Variable names, coordinate system rotation, vertical levels, and accepted formats can all change. See "How to find correct parameters" above.
- **CDO remapbil fails**: The downloaded subset must fully cover the `UKR-rll.grid` extent with margin for interpolation. Ensure the rotated bbox is large enough.
