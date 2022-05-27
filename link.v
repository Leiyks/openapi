module openapi

import x.json2 { Any }
import json

pub struct Link {
pub mut:
	operation_ref string
	operation_id  string
	request_body  Any
	parameters    map[string]Any
	description   string
	server        Server
}

pub fn (mut link Link) from_json(json Any) ? {
	for key, value in json.as_map() {
		match key {
			'operationRef' {
				link.operation_ref = value.str()
			}
			'operationId' {
				link.operation_id = value.str()
			}
			'requestBody' {
				link.request_body = value
			}
			'parameters' {
				link.parameters = decode_map_any(value.json_str())?
			}
			'description' {
				link.description = value.str()
			}
			'server' {
				link.server = decode<Server>(value.json_str())?
			}
			else {}
		}
	}

	if link.operation_ref != '' && link.operation_id != '' {
		return error('Failed Link decoding: "operationId" and "operationRef" are mutually exclusives')
	}
}
