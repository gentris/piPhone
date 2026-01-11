.PHONY: format

format:
	swift-format format --recursive --in-place --parallel --configuration .swift-format.json .
