# MuthoBazar

Monorepo scaffold for:

- apps/customer_app
- apps/staff_app
- apps/admin_web
- packages/*
- firebase/*
- docs/*
- tools/*

## Quick start

`ash
dart pub global activate melos
melos bootstrap
melos run pub_get
melos run analyze
`

## Optional Flutter shell generation

You can generate missing platform shells later:

`ash
cd apps/customer_app && flutter create .
cd ../staff_app && flutter create .
cd ../admin_web && flutter create .
`
"@
}

function Get-MetadataContent {
@"
# Placeholder metadata file for scaffold stage
version:
  revision: scaffold
  channel: stable
project_type: app