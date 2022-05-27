module openapi

import x.json2 { Any }
import json

pub struct Info {
pub mut:
	title            string
	version          string
	terms_of_service string
	description      string
	contact          Contact
	license          License
}

pub fn (mut info Info) from_json(json Any) ? {
	object := json.as_map()
	check_required<Info>(object, 'title', 'version')?

	for key, value in object {
		match key {
			'title' {
				info.title = value.str()
			}
			'version' {
				info.version = value.str()
			}
			'termsOfService' {
				info.terms_of_service = value.str()
			}
			'description' {
				info.description = value.str()
			}
			'contact' {
				info.contact = decode<Contact>(value.json_str())?
			}
			'license' {
				info.license = decode<License>(value.json_str())?
			}
			else {}
		}
	}

	if info.terms_of_service != '' && !check_url_regex(info.terms_of_service) {
		return error('Failed Info decoding: "termsOfService" do not match url regex expression')
	}
}

// ---------------------------------------- //

pub struct Contact {
pub mut:
	name  string
	url   string
	email string
}

pub fn (mut contact Contact) from_json(json Any) ? {
	for key, value in json.as_map() {
		match key {
			'name' { contact.name = value.str() }
			'url' { contact.url = value.str() }
			'email' { contact.email = value.str() }
			else {}
		}
	}

	if contact.url != '' && !check_url_regex(contact.url) {
		return error('Failed Contact decoding: "url" do not match url regex expression')
	}

	if contact.email != '' && !check_email_regex(contact.email) {
		return error('Failed Contact decoding: "email" do not match email regex expression')
	}
}

// ---------------------------------------- //

pub struct License {
pub mut:
	name string
	url  string
}

pub fn (mut license License) from_json(json Any) ? {
	object := json.as_map()
	check_required<License>(object, 'name')?

	for key, value in object {
		match key {
			'name' { license.name = value.str() }
			'url' { license.url = value.str() }
			else {}
		}
	}

	if license.url != '' && !check_url_regex(license.url) {
		return error('Failed License decoding: "url" do not match url regex expression')
	}
}
