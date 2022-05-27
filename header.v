module openapi

import x.json2 { Any }
import json

pub struct Header {
	Parameter
}

pub fn (mut header Header) from_json(json Any) ? {
	object := json.as_map()
	for key, value in object {
		match key {
			'required' {
				header.required = value.bool()
			}
			'allowEmptyValue' {
				header.allow_empty_value = value.bool()
			}
			'description' {
				header.description = value.str()
			}
			'deprecated' {
				header.deprecated = value.bool()
			}
			else {}
		}
	}
	header.validate(object)?
}

fn (mut header Header) validate(object map[string]Any) ? {
	if 'name' in object || 'in' in object {
		return error('Failed Header decoding: "name" and "in" must not be specified.')
	}

	if 'example' in object && 'examples' in object {
		return error('Failed Header decoding: "example" and "examples" are mutually exclusives')
	}

	if 'style' !in object {
		header.style = 'simple'
	}

	if header.style == 'form' && 'explode' !in object {
		header.explode = true
	}

	if header.content.len > 1 {
		return error('Failed Header decoding: "content" must contain only one entry.')
	}
}
