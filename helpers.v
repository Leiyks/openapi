module openapi

import x.json2 { Any, raw_decode }
import json
import regex

pub fn decode<T>(src string) ?T {
	res := raw_decode(src)?
	mut typ := T{}
	typ.from_json(res)?
	return typ
}

// ---------------------------------------- //

pub fn decode_array<T>(src string) ?[]T {
	json := raw_decode(src)?
	mut typ := []T{}

	for value in json.arr() {
		typ << decode<T>(value.json_str())?
	}
	return typ
}

pub fn decode_array_string(src string) ?[]string {
	json := raw_decode(src)?
	return json.arr().map(fn (elt Any) string {
		return elt.str()
	})
}

pub fn decode_array_any(src string) ?[]Any {
	json := raw_decode(src)?
	return json.arr().map(fn (elt Any) Any {
		return elt
	})
}

// ---------------------------------------- //

pub fn decode_map<T>(src string) ?map[string]T {
	json := raw_decode(src)?
	mut typ := map[string]T{}

	for key, value in json.as_map() {
		typ[key] = decode<T>(value.json_str())?
	}
	return typ
}

pub fn decode_map_string(src string) ?map[string]string {
	json := raw_decode(src)?
	mut typ := map[string]string{}

	for key, value in json.as_map() {
		typ[key] = value.str()
	}
	return typ
}

pub fn decode_map_any(src string) ?map[string]Any {
	json := raw_decode(src)?
	mut typ := map[string]Any{}

	for key, value in json.as_map() {
		typ[key] = value
	}
	return typ
}

pub fn decode_map_sumtype<T>(src string, verif fn (string) bool) ?map[string]ObjectRef<T> {
	json := raw_decode(src)?
	mut typ := map[string]ObjectRef<T>{}

	for key, value in json.as_map() {
		typ[key] = from_json<T>(value)?
	}
	return typ
}

// ---------------------------------------- //

pub fn check_required<T>(object map[string]Any, required_fields ...string) ? {
	for field in required_fields {
		if field !in object {
			return error('Failed $T.name decoding: "$field" not specified !')
		}
	}
}

// ---------------------------------------- //

fn fake_predicat(str string) bool {
	return true
}

fn check_key_regex(str string) bool {
	mut reg := regex.regex_opt(r'^[\w\.\-]+$') or { panic('Failed to initialize regex expression') }
	return reg.matches_string(str)
}

fn check_url_regex(str string) bool {
	mut reg := regex.regex_opt(r'^(https?://)?(www\.)?[\w\-@:%\+~#=]{2,256}\.[\a]{2,6}[\-\w@:%\+~#?&//=\.]*$') or {
		panic('Failed to initialize regex expression')
	}
	return reg.matches_string(str)
}

fn check_email_regex(str string) bool {
	mut reg := regex.regex_opt(r'^\S+@\S+\.\S+$') or {
		panic('Failed to initialize regex expression')
	}
	return reg.matches_string(str)
}

fn check_http_code_regex(str string) bool {
	mut reg := regex.regex_opt(r'^([1-5][\d][\d])|([1-5]XX)$') or {
		panic('Failed to initialize regex expression')
	}
	return reg.matches_string(str)
}
