module openapi

import x.json2 { Any, raw_decode }
import json

pub struct Reference {
pub mut:
	ref string
}

pub fn (mut reference Reference) from_json(json Any) ? {
	object := json.as_map()
	check_required<Reference>(object, '\$ref')?

	for key, value in object {
		match key {
			'\$ref' {
				reference.ref = value.str()
			}
			else {}
		}
	}
}

// ---------------------------------------- //

pub type ObjectRef<T> = Reference | T

pub fn from_json<T>(json Any) ?ObjectRef<T> {
	if tmp := decode<Reference>(json.json_str()) {
		return tmp
	}
	return decode<T>(json.json_str()) or {
		return error('Failed ObjectRef<$T.name> decoding: $err')
	}
}

// ---------------------------------------- //

pub fn (mut object []ObjectRef<Parameter>) from_json(json Any) ? {
	for value in json.arr() {
		str := raw_decode(value.json_str())?
		object << from_json<Parameter>(str)?
	}
}
