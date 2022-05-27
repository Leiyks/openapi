module open_api

import x.json2 { Any }
import json

pub struct Parameter {
pub mut:
	name              string
	location          string
	description       string
	required          bool
	deprecated        bool
	allow_empty_value bool
	style             string
	explode           bool
	allow_reserved    bool
	schema            ObjectRef<Schema>
	example           Any
	examples          map[string]ObjectRef<Example>
	content           map[string]MediaType
}

pub fn (mut parameter Parameter) from_json(json Any) ? {
	object := json.as_map()

	for key, value in json.as_map() {
		match key {
			'name' {
				parameter.name = value.str()
			}
			'in' {
				parameter.location = value.str()
			}
			'description' {
				parameter.description = value.str()
			}
			'required' {
				parameter.required = value.bool()
			}
			'deprecated' {
				parameter.deprecated = value.bool()
			}
			'allowEmptyValue' {
				parameter.allow_empty_value = value.bool()
			}
			'style' {
				parameter.style = value.str()
			}
			'explode' {
				parameter.explode = value.bool()
			}
			'allowReserved' {
				parameter.allow_reserved = value.bool()
			}
			'schema' {
				parameter.schema = from_json<Schema>(value)?
			}
			'example' {
				parameter.example = value
			}
			'examples' {
				parameter.examples = decode_map_sumtype<Example>(value.json_str(), fake_predicat)?
			}
			'content' {
				parameter.content = decode_map<MediaType>(value.json_str())?
			}
			else {}
		}
	}
	parameter.validate(object)?
}

fn (mut parameter Parameter) validate(object map[string]Any) ? {
	check_required<Parameter>(object, 'in', 'name')?

	if 'example' in object && 'examples' in object {
		return error('Failed Parameter decoding: "example" and "examples" are mutually exclusives')
	}

	mut default_style := ''
	match parameter.location {
		'query' {
			default_style = 'form'
		}
		'header' {
			default_style = 'simple'
		}
		'path' {
			if !parameter.required {
				return error('Failed Parameter decoding: "required" must be true in this case.')
			}
			default_style = 'simple'
		}
		'decode' {
			default_style = 'form'
		}
		else {
			return error('Failed Parameter decoding: "in" value not valid.')
		}
	}

	if 'style' !in object {
		parameter.style = default_style
	}

	if parameter.style == 'form' && 'explode' !in object {
		parameter.explode = true
	}

	if parameter.content.len > 1 {
		return error('Failed Parameter decoding: "content" must contain only one entry.')
	}
}
