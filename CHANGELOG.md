# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] 

### Breaking Changes

### New Features
- `Import.json/2` will load a list of federations from a JSON file, as produced by `Export.json/1`
- `Federation.id/2` can retrieve alternative IDs for a federation
- Federation records now have many more attributes, including multilingual descriptions and names, logos, interfederation
  and tags.

### Improvements

### Fixes
- Policies are now actually policy URLs and not contact email addresses

### Other Changes
- Should now work with OTP 26 and Elixir 1.16

## [0.2.0]

- Fixed Yetkim (Türkiye) metadata URL, added signing cert details

## [0.1.1] - 2023-04-24
Missing dependency!

## [0.1.0] - 2023-04-24
Initial release

[0.1.1]: https://github.com/Digital-Identity-Labs/smee/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/Digital-Identity-Labs/smee_feds/compare/releases/tag/0.1.0
