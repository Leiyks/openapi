module openapi

import x.json2 { Any }
import json

pub type SecurityRequirement = map[string][]string

pub fn (mut requirement SecurityRequirement) from_json(json Any) ? {
	mut tmp := map[string][]string{}
	for key, value in json.as_map() {
		tmp[key] = decode_array_string(value.json_str())?
	}
	requirement = tmp
	// Todo: Check that key match the '{name}' type
}

// ---------------------------------------- //

pub struct SecurityScheme {
pub mut:
	security_type       string
	location            string
	open_id_connect_url string
	name                string
	scheme              string
	flows               OAuthFlows
	bearer_format       string
	description         string
}

pub fn (mut security_scheme SecurityScheme) from_json(json Any) ? {
	object := json.as_map()
	for key, value in json.as_map() {
		match key {
			'type' {
				security_scheme.security_type = value.str()
			}
			'in' {
				security_scheme.location = value.str()
			}
			'openIdConnectUrl' {
				security_scheme.open_id_connect_url = value.str()
			}
			'name' {
				security_scheme.name = value.str()
			}
			'scheme' {
				security_scheme.scheme = value.str()
			}
			'flows' {
				security_scheme.flows = decode<OAuthFlows>(value.json_str())?
			}
			'bearerFormat' {
				security_scheme.bearer_format = value.str()
			}
			'description' {
				security_scheme.description = value.str()
			}
			else {}
		}
	}
	security_scheme.validate(object)?
}

fn (mut security_scheme SecurityScheme) validate(object map[string]Any) ? {
	check_required<SecurityScheme>(object, 'type')?

	match security_scheme.security_type {
		'apiKey' {
			check_required<SecurityScheme>(object, 'name', 'in')?
			if security_scheme.location !in ['query', 'header', 'cookie'] {
				return error('Failed SecurityScheme decoding: "in" is not valid $security_scheme.location')
			}
		}
		'http' {
			check_required<SecurityScheme>(object, 'scheme')?
		}
		'oauth2' {
			check_required<SecurityScheme>(object, 'flows')?
		}
		'openIdConnect' {
			check_required<SecurityScheme>(object, 'openIdConnectUrl')?
			if !check_url_regex(security_scheme.open_id_connect_url) {
				return error('Failed SecurityScheme decoding: "OpenIdConnectUrl" do not match url regex expression')
			}
		}
		else {
			return error('Failed SecurityScheme decoding: "type" is not valid $security_scheme.security_type')
		}
	}
}

// ---------------------------------------- //

pub struct OAuthFlows {
pub mut:
	client_credentials OAuthFlow
	authorization_code OAuthFlow
	implicit           OAuthFlow
	password           OAuthFlow
}

pub fn (mut flows OAuthFlows) from_json(json Any) ? {
	for key, value in json.as_map() {
		match key {
			'clientCredentials' {
				flows.client_credentials = decode<OAuthFlow>(value.json_str())?
				check_required<OAuthFlow>(value.as_map(), 'tokenUrl')?
			}
			'authorizationCode' {
				flows.authorization_code = decode<OAuthFlow>(value.json_str())?
				check_required<OAuthFlow>(value.as_map(), 'authorizationUrl', 'tokenUrl')?
			}
			'implicit' {
				flows.implicit = decode<OAuthFlow>(value.json_str())?
				check_required<OAuthFlow>(value.as_map(), 'authorizationUrl')?
			}
			'password' {
				flows.password = decode<OAuthFlow>(value.json_str())?
				check_required<OAuthFlow>(value.as_map(), 'tokenUrl')?
			}
			else {}
		}
	}
}

// ---------------------------------------- //

pub struct OAuthFlow {
pub mut:
	authorization_url string
	token_url         string
	scopes            map[string]string
	refresh_url       string
}

pub fn (mut flow OAuthFlow) from_json(json Any) ? {
	object := json.as_map()
	check_required<OAuthFlow>(object, 'scopes')?

	for key, value in object {
		match key {
			'authorizationUrl' {
				flow.authorization_url = value.str()
			}
			'tokenUrl' {
				flow.token_url = value.str()
			}
			'scopes' {
				flow.scopes = decode_map_string(value.json_str())?
			}
			'refreshUrl' {
				flow.refresh_url = value.str()
			}
			else {}
		}
	}
	flow.validate()?
}

fn (mut flow OAuthFlow) validate() ? {
	if flow.authorization_url != '' && !check_url_regex(flow.authorization_url) {
		return error('Failed OAuthFlow decoding: "AuthorizationUrl" do not match url regex expression')
	}
	if flow.token_url != '' && !check_url_regex(flow.token_url) {
		return error('Failed OAuthFlow decoding: "tokenUrl" do not match url regex expression')
	}
	if flow.refresh_url != '' && !check_url_regex(flow.refresh_url) {
		return error('Failed OAuthFlow decoding: "refreshUrl" do not match url regex expression')
	}
}
