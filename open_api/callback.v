module open_api

import x.json2 { Any }
import json

pub type Callback = map[string]PathItem

pub fn (mut callback Callback) from_json(json Any) ? {
	mut tmp := map[string]PathItem{}
	for key, value in json.as_map() {
		tmp[key] = decode<PathItem>(value.json_str())?
	}
	callback = tmp
}
