.PHONY: format

format:
	@command -v swift-format >/dev/null 2>&1 || { \
		echo "swift-format not found. Installing via Homebrew..."; \
		brew install swift-format; \
	}
	swift-format format --recursive --in-place --parallel --configuration .swift-format.json .
