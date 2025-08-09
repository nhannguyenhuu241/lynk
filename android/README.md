# Android Configuration

This Android project has been configured to support multiple languages and flexible configuration management.

## Configuration Files

### gradle.properties
Contains default configuration values that can be overridden:
- `applicationId`: App package name
- `appName`: Default app name
- `versionName` & `versionCode`: App version
- `storeFile`, `storePassword`, `keyAlias`, `keyPassword`: Signing configuration
- `authRedirectScheme`: OAuth redirect scheme

### local.properties (sensitive)
Should contain environment-specific and sensitive values. Copy from `local.properties.example` and customize.
**Important**: Never commit `local.properties` to version control.

### String Resources
- `res/values/strings.xml`: Vietnamese/default strings
- `res/values-en/strings.xml`: English strings

## Multi-language Support

The app name will automatically display in the correct language based on device settings:
- Vietnamese: "Lynk Ấn"
- English: "Lynk An"

## Security Best Practices

1. Move sensitive values (passwords, API keys) to `local.properties`
2. Use environment variables in CI/CD pipelines
3. Never commit signing keys or passwords to version control

## Customization

To customize the app for different environments:

1. Copy `local.properties.example` to `local.properties`
2. Update values in `local.properties`
3. Modify string resources for different languages
4. Update app icons in `res/mipmap-*` directories

## Build Configuration

The build.gradle uses property checks to provide fallback values:
```gradle
applicationId = project.hasProperty('applicationId') ? project.applicationId : 'com.life.lynkan.lynk_an'
```

This ensures the app builds even if properties are missing, while allowing full customization when needed.