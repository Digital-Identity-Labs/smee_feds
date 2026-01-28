# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-01-28

Mostly a bugfix release, but with updated dependencies that *may* cause issues and a couple of small new features.

* Update development tooling to latest Elixir and Erlang (1.19 / 28)
* Update deps
* Elixir 1.19 compatibility

## [0.3.1] - 2024-03-21

## Fixes
- Improvements and fixes to the built-in example data, more federations are now usable (75 I think)

### Improvements
- The smoke test mix task `smee_feds.gen.data_tests` has been improved, and smoketests updated
- Tags added to indicate federations that seem to require fast connections (`noSlow`)
- Tags added to indicate federations that sometimes seem to have TLS or CA issues with Smee

## [0.3.0] - 2024-02-26

### Breaking Changes
- You have to explicitly pass a list of federations to most functions now, they will *not* default to the built-in set.
  This is to make it clearer which list of federations is being used, to avoid the default set being used by mistake.
- `SmeeFeds.federations/2` is now `SmeeFeds.take/2`, a list version of `SmeeFeds.get/2`.
- The parameters for `SmeeFeds.publisher/2` have been reversed, so that the federation list if the first, as for other
  functions in the module.
- "mailto:" scheme is removed from contact email addresses

### New Features
- `Import.json/2` will load a list of federations from a JSON file, as produced by `Export.json/1`
- `Federation.id/2` can retrieve alternative IDs for a federation
- `Federation.get_by/3` can find federation records by various ID types (Smee, URI, or anything in `alt_id` fields)
- `Filter.id_type/3` will filter federations by ID type - can be used to select records in other organization's lists.
  Many other new Federation filters have been added (mostly for the new Federation struct attributes)
- Default data can now be specified at runtime, using config `:smee_feds, :federations`
- Federation records now have many more attributes, including multilingual descriptions and names, logos, interfederation
  and tags.
- Federation structs can be encoded to JSON using `Jason`, and printed as strings in the same format as `Smee`
  structs.
- Federations and Sources can now have tags added automatically, using `autotag: true` option or by passing the 
  Federation struct though `Federation.autotag!/2`. 
- You can autotag entire lists of federations at once with `SmeeFeds.autotag!/2`
- Federation sources now contain their federation's ID.
- Multilingual `Federation.displayname/2` and `Federation.description/2` getter functions
- Values present in ID, protocol, tags, type and structure fields can be listed with various new functions such as
  `SmeeFeds.tags/1` and `SmeeFeds.types/1`, and so on.

### Improvements
- Example federation data has been expanded with more fields and more data, links fixed, and generally improved.

### Fixes
- Policies are now actually policy URLs and not contact email addresses

### Other Changes
- Should now work with OTP 26 and Elixir 1.16
- New Mix scripts for displaying different aspect of the default federations, to make review easier
- The script for building data tests is now a Mix task (`smee_feds.gen.data_tests`)

## [0.2.0]

- Fixed Yetkim (Türkiye) metadata URL, added signing cert details

## [0.1.1] - 2023-04-24
Missing dependency!

## [0.1.0] - 2023-04-24
Initial release

[0.3.1] https://github.com/Digital-Identity-Labs/smee/compare/0.3.0...0.3.1
[0.3.0] https://github.com/Digital-Identity-Labs/smee/compare/0.2.0...0.3.0
[0.2.0] https://github.com/Digital-Identity-Labs/smee/compare/0.1.1...0.2.0
[0.1.1]: https://github.com/Digital-Identity-Labs/smee/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/Digital-Identity-Labs/smee_feds/compare/releases/tag/0.1.0
