module openapi

import x.json2 { Any }
import json

pub struct Components {
pub mut:
	security_schemes map[string]ObjectRef<SecurityScheme>
	request_bodies   map[string]ObjectRef<RequestBody>
	schemas          map[string]ObjectRef<Schema>
	responses        map[string]ObjectRef<Response>
	parameters       map[string]ObjectRef<Parameter>
	examples         map[string]ObjectRef<Example>
	headers          map[string]ObjectRef<Header>
	links            map[string]ObjectRef<Link>
	callbacks        map[string]ObjectRef<Callback>
}

pub fn (mut components Components) from_json(json Any) ? {
	for key, value in json.as_map() {
		match key {
			'securitySchemes' {
				components.security_schemes = decode_map_sumtype<SecurityScheme>(value.json_str(),
					check_key_regex)?
			}
			'requestBodies' {
				components.request_bodies = decode_map_sumtype<RequestBody>(value.json_str(),
					check_key_regex)?
			}
			'schemas' {
				components.schemas = decode_map_sumtype<Schema>(value.json_str(), check_key_regex)?
			}
			'responses' {
				components.responses = decode_map_sumtype<Response>(value.json_str(),
					check_key_regex)?
			}
			'parameters' {
				components.parameters = decode_map_sumtype<Parameter>(value.json_str(),
					check_key_regex)?
			}
			'examples' {
				components.examples = decode_map_sumtype<Example>(value.json_str(), check_key_regex)?
			}
			'headers' {
				components.headers = decode_map_sumtype<Header>(value.json_str(), check_key_regex)?
			}
			'links' {
				components.links = decode_map_sumtype<Link>(value.json_str(), check_key_regex)?
			}
			'callbacks' {
				components.callbacks = decode_map_sumtype<Callback>(value.json_str(),
					check_key_regex)?
			}
			else {}
		}
	}
	components.validate()?
}

fn check_keys(keys []string) ? {
	keys.map(fn (key string) ? {
		if !check_key_regex(key) {
			return error('Failed Components Decoding: $key do not respect key regex format.')
		}
	})
}

fn (mut components Components) validate() ? {
	check_keys(components.security_schemes.keys())?
	check_keys(components.request_bodies.keys())?
	check_keys(components.schemas.keys())?
	check_keys(components.responses.keys())?
	check_keys(components.parameters.keys())?
	check_keys(components.examples.keys())?
	check_keys(components.headers.keys())?
	check_keys(components.links.keys())?
	check_keys(components.callbacks.keys())?
}

pub fn (components Components) get_basic_http_schemes() []string {
	mut keys := []string{}

	for key, value in components.security_schemes {
		if value is SecurityScheme {
			tmp := SecurityScheme{
				...value
			}
			if tmp.security_type.to_lower() == 'http' && tmp.scheme.to_lower() == 'basic' {
				keys << key
			}
		}
	}

	return keys
}
