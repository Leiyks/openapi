module openapi

import x.json2 { Any }
import json

pub type Responses = map[string]ObjectRef<Response>

pub fn (mut responses Responses) from_json(json Any) ? {
	if json.str() == '' {
		return
	}

	mut tmp := map[string]ObjectRef<Response>{}
	for key, value in json.as_map() {
		if check_http_code_regex(key) || key == 'default' {
			tmp[key] = from_json<Response>(value)?
		} else {
			return error('Failed Responses decoding: invalid http code value $key')
		}
	}
	responses = tmp
}

// ---------------------------------------- //

pub struct Response {
pub mut:
	description string
	headers     map[string]ObjectRef<Header>
	content     map[string]MediaType
	links       map[string]ObjectRef<Link>
}

pub fn (mut response Response) from_json(json Any) ? {
	object := json.as_map()
	check_required<Response>(object, 'description')?

	for key, value in object {
		match key {
			'description' {
				response.description = value.str()
			}
			'headers' {
				response.headers = decode_map_sumtype<Header>(value.json_str(), fake_predicat)?
			}
			'content' {
				response.content = decode_map<MediaType>(value.json_str())?
			}
			'links' {
				response.links = decode_map_sumtype<Link>(value.json_str(), fake_predicat)?
			}
			else {}
		}
	}

	if 'Content-Type' in response.headers {
		response.headers.delete('Content-Type')
	}

	for key in response.links.keys() {
		if !check_key_regex(key) {
			return error('Failed Response decoding: "links" key do not comply with the format.')
		}
	}
}
