# openapi
An easy-to-use vlang module to parse OpenApi3 files into usable structs.
This module follows the following specification: [OpenApi 3](https://swagger.io/specification/)

## Installation

#### From VPM

```sh
v install Leiyks.openapi
```

then import it with:

```go
import Leiyks.openapi
```

#### From Github

```sh
v install --git https://github.com/Leiyks/openapi
```

then import it with:

```go
import openapi
```

## Usage

To use this module, you need to load your JSON OpenApi file into a string before parsing it.
If you want to parse YAML files instead you can use the following module: [yaml](https://github.com/jdonnerstag/vlang-yaml)

Then you just need to call the decode function to have a usable struct:

```go
import openapi

fn function(path string) ? {
    mut content := os.read_file(path)?
    open_api := openapi.decode<openapi.OpenApi>(content)?
    // Do amazing things
}
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
