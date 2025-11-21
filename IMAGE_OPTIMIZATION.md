# Image Optimization Guide

This guide provides recommendations for optimizing images to reduce app size.

## Current Image Assets

All current images are being used in the app:
- `logo_launcher.svg` - Used in header
- `logo_centered.png` - Used for adaptive icon
- `logo_mipmap.png` - Used for launcher icons
- `splash-img.png` - Used in splash screen
- `qr-code.jpeg` - Used in settings screen
- `hamkari-meli.png` - Used in settings screen
- `references/*.png` - 6 PNG files for human rights organizations

## Optimization Recommendations

### 1. PNG Compression

Use tools to compress PNG files without quality loss:

**Using pngquant (recommended):**
```bash
# Install pngquant
brew install pngquant  # macOS
# or
sudo apt-get install pngquant  # Linux

# Compress PNG files
pngquant --quality=65-80 --ext .png --force assets/images/logo_centered.png
pngquant --quality=65-80 --ext .png --force assets/images/logo_mipmap.png
for file in assets/images/references/*.png; do
    pngquant --quality=65-80 --ext .png --force "$file"
done
```

**Using online tools:**
- [TinyPNG](https://tinypng.com/) - Free, up to 20 images at once
- [Squoosh](https://squoosh.app/) - Google's image compression tool

### 2. JPEG Optimization

For `qr-code.jpeg`:

```bash
# Using jpegoptim
brew install jpegoptim  # macOS
jpegoptim --max=85 --strip-all assets/images/adjective/qr-code.jpeg

# Or using ImageMagick
convert assets/images/adjective/qr-code.jpeg -quality 85 -strip assets/images/adjective/qr-code-optimized.jpeg
```

### 3. Logo Optimization

- `logo_mipmap.png` (1024x1024): Should be exactly 1024x1024, no larger
- `logo_centered.png`: Should match the required size for adaptive icon (usually 512x512 or 1024x1024)
- Consider using WebP format for Android (smaller file size)

### 4. Splash Image Optimization

- `splash-img.png`: Should be optimized for the target screen sizes
- Consider using different sizes for different screen densities
- Use WebP format if possible (Android supports WebP natively)

### 5. Reference Images

The 6 PNG files in `references/` folder:
- Should be optimized individually
- Consider using WebP format
- Target size: 200-300KB per image (or less)

## Expected Size Reduction

After optimization:
- PNG files: 30-50% size reduction
- JPEG files: 20-40% size reduction
- Total image size reduction: ~2-5 MB

## Tools Summary

1. **pngquant** - PNG compression (command line)
2. **TinyPNG** - Online PNG/JPEG compression
3. **Squoosh** - Google's image compression tool
4. **jpegoptim** - JPEG optimization (command line)
5. **ImageMagick** - General image processing

## Notes

- Always keep original files as backup
- Test images after compression to ensure quality is acceptable
- SVG files are already optimized (vector format)
- Consider using WebP format for better compression (Android supports it natively)

