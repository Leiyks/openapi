module open_api

import x.json2 { Any }
import json
import regex

pub struct Schema {
pub mut:
	title             string
	multiple_of       f64
	maximum           f64
	minimum           f64
	exclusive_maximum bool
	exclusive_minimum bool
	max_length        u64
	min_length        u64
	pattern           string
	max_items         u64
	min_items         u64
	unique_items      bool
	max_properties    u64
	min_properties    u64
	required          []string
	enum_values       []Any

	type_schema           string
	all_of                ObjectRef<Schema>
	one_of                ObjectRef<Schema>
	any_of                ObjectRef<Schema>
	not                   ObjectRef<Schema>
	items                 ObjectRef<Schema>
	properties            map[string]ObjectRef<Schema>
	additional_properties ObjectRef<Schema>
	description           string
	format                string
	default_value         Any

	nullable      bool
	discriminator Discriminator
	read_only     bool
	write_only    bool
	xml           XML
	external_docs ExternalDocumentation
	example       Any
	deprecated    bool
}

pub fn (mut schema Schema) from_json(json Any) ? {
	object := json.as_map()
	for key, value in object {
		match key {
			'title' {
				schema.title = value.str()
			}
			'pattern' {
				schema.pattern = value.str()
			}
			'type' {
				schema.type_schema = value.str()
			}
			'description' {
				schema.description = value.str()
			}
			'format' {
				schema.format = value.str()
			}
			'multipleOf' {
				schema.multiple_of = value.f64()
			}
			'maximum' {
				schema.maximum = value.f64()
			}
			'minimum' {
				schema.minimum = value.f64()
			}
			'maxLength' {
				schema.max_length = value.u64()
			}
			'minLength' {
				schema.min_length = value.u64()
			}
			'maxItems' {
				schema.max_items = value.u64()
			}
			'minItems' {
				schema.min_items = value.u64()
			}
			'maxProperties' {
				schema.max_properties = value.u64()
			}
			'minProperties' {
				schema.min_properties = value.u64()
			}
			'exclusiveMinimum' {
				schema.exclusive_minimum = value.bool()
			}
			'exclusiveMaximum' {
				schema.exclusive_maximum = value.bool()
			}
			'UniqueItems' {
				schema.unique_items = value.bool()
			}
			'nullable' {
				schema.nullable = value.bool()
			}
			'readOnly' {
				schema.read_only = value.bool()
			}
			'writeOnly' {
				schema.write_only = value.bool()
			}
			'deprecated' {
				schema.deprecated = value.bool()
			}
			'default' {
				schema.default_value = value
			}
			'example' {
				schema.example = value
			}
			'discriminator' {
				schema.discriminator = decode<Discriminator>(value.json_str())?
			}
			'xml' {
				schema.xml = decode<XML>(value.json_str())?
			}
			'externalDocs' {
				schema.external_docs = decode<ExternalDocumentation>(value.json_str())?
			}
			'allOf' {
				schema.all_of = from_json<Schema>(value)?
			}
			'oneOf' {
				schema.one_of = from_json<Schema>(value)?
			}
			'anyOf' {
				schema.any_of = from_json<Schema>(value)?
			}
			'not' {
				schema.not = from_json<Schema>(value)?
			}
			'items' {
				schema.items = from_json<Schema>(value)?
			}
			'additionalProperties' {
				schema.additional_properties = from_json<Schema>(value)?
			}
			'required' {
				schema.required = decode_array_string(value.json_str())?
			}
			'enum' {
				schema.enum_values = decode_array_any(value.json_str())?
			}
			'properties' {
				schema.properties = decode_map_sumtype<Schema>(value.json_str(), fake_predicat)?
			}
			else {}
		}
		schema.validate(object)?
	}
}

fn (mut schema Schema) validate(object map[string]Any) ? {
	if 'readOnly' in object && 'writeOnly' in object {
		return error('Failed Schema decoding: Schema cannot be writeOnly and readOnly')
	}

	mut format_values := []string{}
	match schema.type_schema {
		'' {}
		'boolean' {}
		'object' {}
		'array' {
			if 'items' !in object {
				println(schema.items)
				return error('Failed Schema decoding: "items" must be non-null if "type" is "array"')
			}
		}
		'integer' {
			format_values = ['int32', 'int64']
		}
		'number' {
			format_values = ['float', 'double']
		}
		'string' {
			format_values = ['byte', 'binary', 'date', 'date-time', 'password', 'iri',
				'iri-reference', 'uri-template', 'idn-email', 'idn-hostname', 'json-pointer',
				'relative-json-pointer', 'regex', 'time', 'duration', 'uuid', 'email', 'hostname',
				'ipv4', 'ipv6', 'uri', 'uri-reference']
			if schema.pattern != '' {
				regex.regex_opt(schema.pattern) or {
					return error('Failed Schema decoding: invalid pattern regex $schema.pattern')
				}
			}
		}
		'null' {
			if !schema.nullable {
				return error('Failed Schema decoding: "nullable" must be true to have a null "type"')
			}
		}
		else {
			return error('Failed Schema decoding: unsupported type $schema.type_schema')
		}
	}

	if schema.format != '' && format_values.len != 0 && schema.format !in format_values {
		return error('Failed Schema decoding: unsupported format value $schema.format')
	}
}

// ---------------------------------------- //

pub struct Discriminator {
pub mut:
	property_name string
	mapping       map[string]string
}

pub fn (mut discriminator Discriminator) from_json(json Any) ? {
	object := json.as_map()
	check_required<Discriminator>(object, 'propertyName')?

	for key, value in object {
		match key {
			'propertyName' {
				discriminator.property_name = value.str()
			}
			'mapping' {
				discriminator.mapping = decode_map_string(value.json_str())?
			}
			else {}
		}
	}
}

// ---------------------------------------- //

pub struct XML {
pub mut:
	name      string
	namespace string
	prefix    string
	attribute bool
	wrapped   bool
}

pub fn (mut xml XML) from_json(json Any) ? {
	for key, value in json.as_map() {
		match key {
			'name' {
				xml.name = value.str()
			}
			'namespace' {
				xml.namespace = value.str()
			}
			'prefix' {
				xml.prefix = value.str()
			}
			'attribute' {
				xml.attribute = value.bool()
			}
			'wrapped' {
				xml.wrapped = value.bool()
			}
			else {}
		}
	}
}
