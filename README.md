# Culqi-Ruby

[![Gem Version](https://badge.fury.io/rb/culqi-ruby.svg)](https://badge.fury.io/rb/culqi-ruby)

Nuestra Biblioteca Culqi-Ruby oficial, es compatible con la v2.0 del Culqi API, con el cual tendrás la posibilidad de realizar cobros con tarjetas de débito y crédito, Yape, PagoEfectivo, billeteras móviles y Cuotéalo con solo unos simples pasos de configuración.

Nuestra biblioteca te da la posibilidad de capturar el `status_code` de la solicitud HTTP que se realiza al API de Culqi, así como el `response` que contiene el cuerpo de la respuesta obtenida.

| Versión actual|Culqi API|
|----|----|
| [1.0.0](https://rubygems.org/gems/culqi-ruby) (2023-08-11) |[v2](https://culqi.com/api)|


## Requisitos

- Ruby 3.0.0+
- Afiliate [aquí](https://afiliate.culqi.com/).
- Si vas a realizar pruebas obtén tus llaves desde [aquí](https://integ-panel.culqi.com/#/registro), si vas a realizar transacciones reales obtén tus llaves desde [aquí](https://mipanel.culqi.com/#/registro).

> Recuerda que para obtener tus llaves debes ingresar a tu CulqiPanel > Desarrollo > ***API Keys***.

![alt tag](http://i.imgur.com/NhE6mS9.png)

> Recuerda que las credenciales son enviadas al correo que registraste en el proceso de afiliación.

* Para encriptar el payload debes generar un id y llave RSA  ingresando a CulqiPanel > Desarrollo  > RSA Keys.

## Instalar Dependencias

```bash
gem install bundler
bundle install
```

## Build

```bash
gem build culqi-ruby.gemspec
gem install ./culqi-ruby-{VERSION}.gem
gem push culqi-ruby-{VERSION}.gem
```

## Configuracion

Para empezar a enviar peticiones al API de Culqi debes configurar tu llave pública (pk), llave privada (sk).
Para habilitar encriptación de payload debes configurar tu rsa_id y rsa_public_key.

```ruby

require 'minitest/autorun'
require 'culqi-ruby'

Culqi.public_key = 'pk_test_e94078b9b248675d'
Culqi.secret_key = 'sk_test_c2267b5b262745f0'
Culqi.rsa_id = 'de35e120-e297-4b96-97ef-10a43423ddec'
Culqi.rsa_key = "-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDswQycch0x/7GZ0oFojkWCYv+g
r5CyfBKXc3Izq+btIEMCrkDrIsz4Lnl5E3FSD7/htFn1oE84SaDKl5DgbNoev3pM
C7MDDgdCFrHODOp7aXwjG8NaiCbiymyBglXyEN28hLvgHpvZmAn6KFo0lMGuKnz8
HiuTfpBl6HpD6+02SQIDAQAB
-----END PUBLIC KEY-----"
```

### Encriptar payload

Para encriptar el payload necesitas agregar el siguiente codigo en caso de token.

Ejemplo

```ruby
token_string =  CulqiCRUD.createTokenEncrypt
token_json = JSON.parse(JSON.generate(token_string[0]))
id_value = token_json['object']
assert_equal 'token', id_value
```

## Ejemplos

### Crear Token

```ruby
params ={
      :card_number => '4111111111111111',
      :cvv => '111',
      :currency_code => 'PEN',
      :email => 'test1231@culqi.com',
      :expiration_month => 9,
      :expiration_year => 2025
    }
token, statusCode = Culqi::Token.create(params,  rsa_key, rsa_id)

jsonToken = JSON.parse(token)

puts jsonToken['id']
```

### Crear Cargo

```ruby
params = {
      :amount => 1000,
      :capture => false,
      :currency_code => 'PEN',
      :description => 'Venta de prueba',
      :email => 'test'+SecureRandom.uuid+'@culqi.com',
      :installments => 0,
      :metadata => ({
        :test => 'test123'
      }),
      :source_id => token_json['id']
    }
charge, statusCode = Culqi::Charge.create(params)

jsonCharge = JSON.parse(charge)
```

### Crear Plan

```ruby
params = {
      :amount => 1000,
      :currency_code => 'PEN',
      :interval => 'dias',
      :interval_count => 2,
      :limit => 10,
      :metadata => ({
        :alias => 'plan_test'
      }),
      :name => 'plan-test-'+SecureRandom.uuid,
      :trial_days => 50
    }

plan, statusCode = Culqi::Plan.create(params)

jsonPlan = JSON.parse(plan)
```

### Crear Costumer

```ruby
params = {
      :address => 'Avenida Lima 123213',
      :address_city => 'LIMA',
      :country_code => 'PE',
      :email => 'test'+SecureRandom.uuid+'@culqi.com',
      :first_name => 'William',
      :last_name => 'Muro',
      :metadata => ({
        :other_number => '789953655'
      }),
      :phone_number => 998989789
    }
customer, statusCode = Culqi::Customer.create(params)

jsonCustomer = JSON.parse(customer)
```

### Actualizar Costumer

```ruby
updatecustomer = Culqi::Customer.update('cus_test_F5voBd1yHsCkjSwF',
      :address => 'Av. Lima 123',
      :first_name => 'Will')
```

### Obtener Costumer

```ruby
getcustomer = Culqi::Customer.get('cus_test_F5voBd1yHsCkjSwF')
```

### Crear Card

```ruby
card = Culqi::Card.create(
  :customer_id => jsonCustomer['id'],
  :token_id => jsonToken['id']
)

jsonCard = JSON.parse(card)
```

### Crear Suscripción

```ruby
subscription = Culqi::Subscription.create(
  :card_id => jsonCard['id'],
  :plan_id => jsonPlan['id']
)

jsonSubscription = JSON.parse(subscription)
```

### Crear Reembolso

```ruby
refund = Culqi::Refund.create(
  :amount => 500,
  :charge_id => jsonCharge['id'],
  :reason => 'solicitud_comprador'
)

jsonRefund = JSON.parse(refund)
```

## Pruebas

En la carpeta **/test** encontraras ejemplos para crear un token, charge, plan, órdenes, card, suscripciones, etc.

> Recuerda que si quieres probar tu integración, puedes utilizar nuestras [tarjetas de prueba.](https://docs.culqi.com/es/documentacion/pagos-online/tarjetas-de-prueba/)

Solo debe ejecutar el siguiente comando

```ruby
rake test test_culqi-create.rb
```

Si queremos ejecutar un especifico test método

```ruby
rake test TEST=test/test_culqi-create.rb
rake test TEST=test/test_culqi-create.rb TESTOPTS="--name=test_create_token -v"
```


### Ejemplo Prueba Token

```ruby
token_string =  CulqiCRUD.createToken
token_json = JSON.parse(JSON.generate(token_string[0]))
id_value = token_json['object']
assert_equal 'token', id_value
```

### Ejemplo Prueba Cargo

```ruby
charge_string =  CulqiCRUD.createCharge
charge_json = JSON.parse(JSON.generate(charge_string[0]))
id_value = charge_json['object']
assert_equal 'charge',id_value
```

## Documentación

- [Referencia de API](https://apidocs.culqi.com/)
- [Demo Checkout V4 + Culqi 3DS](https://github.com/culqi/culqi-ruby-demo-checkoutv4-culqi3ds)
- [Wiki](https://github.com/culqi/culqi-python/wiki)


## Changelog

Todos los cambios en las versiones de esta biblioteca están listados en [CHANGELOG](CHANGELOG).

## Autor
Team Culqi

## Licencia
El código fuente de culqi-net está distribuido bajo MIT License, revisar el archivo LICENSE.
