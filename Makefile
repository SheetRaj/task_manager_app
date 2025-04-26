# List of targets that are not actual files
.PHONY: get build run test format analyze clean gen coverage version upgrade

## Install all packages
get:
	flutter pub get

## Build APK for release
build:
	flutter build apk --release

## Run the app
run:
	flutter run

## Run tests
test:
	flutter test

## Format the code
format:
	flutter format lib test

## Analyze the code (linting)
analyze:
	flutter analyze

## Clean the project
clean:
	flutter clean

## Generate files using build_runner
gen:
	flutter pub run build_runner build --delete-conflicting-outputs

## Run tests and generate code coverage
coverage:
	very_good test --coverage

## Show Flutter version info
version:
	flutter --version

## Upgrade all pub packages
upgrade:
	flutter pub upgrade
