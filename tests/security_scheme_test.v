import openapi
import os

fn test_security_scheme_struct_with_oauth() ? {
	content := os.read_file(@VMODROOT + '/testdata/security_scheme.json')?
	security_scheme := openapi.decode<openapi.SecurityScheme>(content)?
	oauthflow := security_scheme.flows.implicit

	assert security_scheme.security_type == 'oauth2'
	assert oauthflow.authorization_url == 'https://example.com/api/oauth/dialog'
	assert oauthflow.scopes.len == 2
	assert oauthflow.scopes['write:pets'] == 'modify pets in your account'
	assert oauthflow.scopes['read:pets'] == 'read your pets'
}

fn test_security_scheme_struct_with_apikey() ? {
	content := '{ "type": "apiKey", "name": "api_key", "in": "header" }'
	security_scheme := openapi.decode<openapi.SecurityScheme>(content)?
	assert security_scheme.security_type == 'apiKey'
	assert security_scheme.name == 'api_key'
	assert security_scheme.location == 'header'
}

fn test_security_scheme_struct_with_http() ? {
	content := '{ "type": "http", "scheme": "bearer", "bearerFormat": "JWT" }'
	security_scheme := openapi.decode<openapi.SecurityScheme>(content)?
	assert security_scheme.security_type == 'http'
	assert security_scheme.scheme == 'bearer'
	assert security_scheme.bearer_format == 'JWT'
}

fn test_security_scheme_struct_basic() ? {
	content := '{ "type": "http", "scheme": "basic" }'
	security_scheme := openapi.decode<openapi.SecurityScheme>(content)?
	assert security_scheme.security_type == 'http'
	assert security_scheme.scheme == 'basic'
}
