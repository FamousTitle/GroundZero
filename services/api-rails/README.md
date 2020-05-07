# API

## JWT

Revocation Strategy: Whitelisted

### Signup

```
POST http://localhost:3001/users

Headers:
    JWT_AUD: web

{
	"user": {
		"email": "asdf@asdf.com",
		"password": "hogehoge1!",
		"password_confirmation": "hogehoge1!"
	}
}

```

### Login

```
POST http://localhost:3001/users/sign_in

Headers:
    JWT_AUD: web

{
	"user": {
		"email": "asdf@asdf.com",
		"password": "hogehoge1!"
	}
}
```

### Logout

```
DELETE http://localhost:3001/users/sign_out

Headers:
    Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI1Iiwic2NwIjoidXNlciIsImF1ZCI6ImlwaG9uZSIsImlhdCI6MTU4ODgzNDAwMiwiZXhwIjoxNTg4ODQ4NDAyLCJqdGkiOiJiYmJiMGZiMC00OWM2LTRkMzYtYjE1YS01NzY0ZDVmNDJjMzAifQ.eJ1BK1O-zspwKo5TtpiC3riskyOhPpkgvJSf7yzyALE
```
