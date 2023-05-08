
BUILD_DIR := ./output
CONTENT_DIR := ./src


.PHONY: clean
clean:
    rm -r $(BUILD_DIR)
    mkdir $(BUILD_DIR)
    mkdir $(BUILD_DIR)/web
    mkdir $(BUILD_DIR)/gemini



