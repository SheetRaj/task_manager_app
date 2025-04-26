# Declare which targets(task) don't need to generate target-file.
.PHONY: all

##

all: analyze format fix run_dev ## Run default tasks. Run in `make` and has no target.

analyze: analyze_lint analyze_custom

help: ## Know all commands.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
			IFS=$$'#' ; \
			help_split=($$help_line) ; \
      help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
			help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
			printf "%-30s    %s\n" $$help_command $$help_info ; \
	done

## --- Basic ---

## Clean the environment.
clean:
	@echo "⚡︎Cleaning the project..."

	@rm -rf pubspec.lock
	@rm -rf ios/Podfile.lock
	@rm -rf ios/Pods
	@rm -rf ios/.symlinks
	@rm -rf ios/Flutter/Flutter.framework
	@rm -rf ios/Flutter/Flutter.podspec
	@rm -rf ~/.pub-cache
	@flutter clean

	@echo "⚡︎Project clean successfully!"

get: ## Get pub packages.
	@echo "⚡︎Getting flutter pub..."

	@flutter pub get
	@cd ios && pod install
	@cd ios && pod update

	@echo "⚡︎Flutter pub get successfully!"

upgrade: ## Upgrade pub packages.
	@echo "⚡︎Upgrading flutter pub..."

	@flutter pub upgrade

	@echo "⚡︎Flutter pub upgrade successfully!"

init: get build_runner ## Generate the files after get the packages.
	@echo "⚡︎Flutter pub get and build_runner successfully!"

clean_get: clean get ## Get packages after cleaning the environment.
	@echo "⚡︎Flutter pub clean and get successfully!"

analyze_lint: ## Analyze the code and find issues.
	@echo "⚡︎Analyzing code..."

	@dart analyze . || (echo "Error in analyzing, some code need to optimize."; exit 99)

	@echo "⚡︎Code is perfect."

format: ## Format the code.
	@echo "⚡︎Formatting code..."

	@dart format ./lib

	@echo "⚡︎Code format successfully!"

fix: ## Fix the code.
	@echo "Fixing code..."

	@dart fix --dry-run
	@dart fix --apply

	@echo "⚡︎Code fix successfully!"

## --- Run ---

run_unit_test: ## Run unit tests.
	@echo "⚡︎Start running unit tests."

	@flutter test || (echo "Error in testing."; exit 99)

	@echo "⚡︎All unit tests are good!"

run_debug: ## Run app in debug.
	@flutter run --debug --flavor dev --target ./lib/main_dev.dart || (echo "Error in running dev."; exit 99)

run_profile: ## Run app in profile.
	@flutter run --profile --profile --flavor dev --target ./lib/main_dev.dart  || (echo "Error in running profile."; exit 99)

run_release: ## Run app in release.
	@flutter run --release --release --flavor dev --target ./lib/main_dev.dart  || (echo "Error in running release."; exit 99)

##
## --- Generate ---

build_runner: ## Run build_runner and generate files automatically.
	@echo "⚡︎Running build_runner..."

	@dart run build_runner build -d

	@echo "⚡︎Run build_runner and generate files successfully!"

build_watch: ## Run build_runner and generate files automatically.
	@echo "⚡︎Running build_runner watch..."

	@dart run build_runner watch -d

	@echo "⚡︎Run build_runner and generate files successfully!"

launcher_icon: ## Generate new app icon images.
	@echo "⚡︎Running flutter_launcher_icons..."

	@dart run flutter_launcher_icons:main -f flutter_launcher_icons*

	@echo "⚡︎Run flutter_launcher_icons and generate files successfully!"

splash: ##
	@echo "⚡︎Running flutter_native_splash..."

	@dart run flutter_native_splash:create

	@echo "⚡︎Run flutter_native_splash and generate files successfully!"

splash_flavor: ##
	@echo "⚡︎Running flutter_native_splash with flavors..."

	@dart run flutter_native_splash:create --flavors dev,prod

	@echo "⚡︎Run flutter_native_splash and generate files successfully!"

image: ## Allocate images to specific folder for resolution
	@dart tools/allocate_images.dart ./assets/images

mason_feature:
	@mason make feature

analyze_custom:
	@dart run custom_lint

fluttergen:
	@fluttergen -c pubspec.yaml

slang:
	@dart run slang

dart_active_mason:
	@dart pub global activate mason_cli
