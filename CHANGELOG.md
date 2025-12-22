# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2025-12-21

### Added
- Integrated `dartantic_ai` (v2.1.0) for both text and image generation.
- Added support for **Gemini 3 Pro Image (Nano Banana Pro)** for high-quality, consistent visuals.
- Implemented **Image-to-Image (I2I)** support to maintain visual continuity across story segments.
- Added on-demand image generation with a manual trigger button.
- Implemented robust safety settings to prevent empty or filtered image responses.
- Added descriptive debug labels to all state signals for easier debugging.

### Changed
- Refactored `GeminiService` and `ImageService` to use the declarative `dartantic_ai` framework.
- Upgraded text generation model to **Gemini 3 Flash**.
- Optimized image generation speed using the "Nano Banana" family of models.
- Updated UI to surface generation errors more gracefully.

### Fixed
- Resolved issues with multimodal context preservation in image generation.
- Fixed various syntax and analyzer errors during the migration to `dartantic_ai`.

## [1.0.0] - 2025-11-18

### Initial Release
- Initial snapshot of the interactive "Choose Your Own Adventure" game.
- Basic integration with Google Generative AI for story and images.
- State management with `signals_flutter`.
