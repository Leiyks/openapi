module open_api

import x.json2 { Any }
import json

pub struct PathItem {
pub mut:
	ref         string
	summary     string
	description string
	get         Operation
	put         Operation
	post        Operation
	delete      Operation
	options     Operation
	head        Operation
	patch       Operation
	trace       Operation
	servers     []Server
	parameters  []ObjectRef<Parameter>
	operations  map[string]Operation
}

pub fn (mut path_item PathItem) from_json(json Any) ? {
	object := json.as_map()
	for key, value in object {
		match key {
			'\$ref' {
				path_item.ref = value.str()
			}
			'summary' {
				path_item.summary = value.str()
			}
			'description' {
				path_item.description = value.str()
			}
			'get' {
				path_item.get = decode<Operation>(value.json_str())?
			}
			'put' {
				path_item.put = decode<Operation>(value.json_str())?
			}
			'post' {
				path_item.post = decode<Operation>(value.json_str())?
			}
			'delete' {
				path_item.delete = decode<Operation>(value.json_str())?
			}
			'options' {
				path_item.options = decode<Operation>(value.json_str())?
			}
			'head' {
				path_item.head = decode<Operation>(value.json_str())?
			}
			'patch' {
				path_item.patch = decode<Operation>(value.json_str())?
			}
			'trace' {
				path_item.trace = decode<Operation>(value.json_str())?
			}
			'servers' {
				path_item.servers = decode_array<Server>(value.json_str())?
			}
			'parameters' {
				path_item.parameters = decode<[]ObjectRef<Parameter>>(value.json_str())?
			}
			else {}
		}
	}
	path_item.validate(object)?
}

fn (mut path_item PathItem) validate(object map[string]Any) ? {
	mut checked := map[string]string{}
	for parameter in path_item.parameters {
		if parameter is Reference {
			continue
		}
		param := parameter as Parameter
		if param.name in checked && checked[param.name] == param.location {
			return error('Failed Path_item decoding: parameter with identical "name" and "in" found.')
		}
		checked[param.name] = param.location
	}
}

pub fn (path_item PathItem) get_operations() map[string]Operation {
	mut operations := map[string]Operation{}

	$for field in PathItem.fields {
		$if field.typ is Operation {
			if path_item.$(field.name).operation_id != '' {
				match field.name {
					'get' { operations[field.name.to_upper()] = path_item.get }
					'put' { operations[field.name.to_upper()] = path_item.put }
					'post' { operations[field.name.to_upper()] = path_item.post }
					'head' { operations[field.name.to_upper()] = path_item.head }
					'trace' { operations[field.name.to_upper()] = path_item.trace }
					'patch' { operations[field.name.to_upper()] = path_item.patch }
					'delete' { operations[field.name.to_upper()] = path_item.delete }
					'options' { operations[field.name.to_upper()] = path_item.options }
					else {}
				}
			}
		}
	}
	return operations
}

// ---------------------------------------- //

pub type Paths = map[string]PathItem

fn clean_path_expression(path string) string {
	mut path_copy := path.clone()
	mut expression := path_copy.find_between('{', '}')

	for expression != '' {
		path_copy = path_copy.replace(expression, '')
		expression = path_copy.find_between('{', '}')
	}

	return path_copy
}

pub fn (mut paths Paths) from_json(json Any) ? {
	mut save_value := map[string][]string{}
	mut tmp := map[string]PathItem{}

	for key, value in json.as_map() {
		if !key.starts_with('/') {
			return error('Failed Paths decoding: path do not start with "/" !')
		}

		value_key := value.as_map().keys()

		for path in tmp.keys() {
			value_ref := save_value[path]

			if clean_path_expression(path) == clean_path_expression(key) {
				verif := ('get' in value_key && 'get' in value_ref)
					|| ('put' in value_key && 'put' in value_ref)
					|| ('post' in value_key && 'post' in value_ref)
					|| ('delete' in value_key && 'delete' in value_ref)
					|| ('options' in value_key && 'options' in value_ref)
					|| ('head' in value_key && 'head' in value_ref)
					|| ('patch' in value_key && 'patch' in value_ref)
					|| ('trace' in value_key && 'trace' in value_ref)

				if verif {
					return error('Failed Paths decoding: Identical path found !')
				}
			}
		}

		save_value[key] = value_key
		tmp[key] = decode<PathItem>(value.json_str())?
	}
	paths = tmp
}
