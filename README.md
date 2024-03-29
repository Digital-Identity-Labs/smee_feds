# SmeeFeds

`SmeeFeds` is a SAML federation data management extension to [Smee](https://github.com/Digital-Identity-Labs/smee) for use in
research, testing and development.

[Smee](https://github.com/Digital-Identity-Labs/smee) has tools for handling the sources of SAML metadata but 
nothing to represent the publishers of metadata. SmeeFeds adds a few tools for handling federations and includes a large
collection of information about research and education federations.

[![Hex pm](http://img.shields.io/hexpm/v/smee_feds.svg?style=flat)](https://hex.pm/packages/smee_feds)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/smee_feds/)
![Github Elixir CI](https://github.com/Digital-Identity-Labs/smee_feds/workflows/Elixir%20CI/badge.svg)

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2FDigital-Identity-Labs%2Fsmee_feds%2Fmain%2Fsmee_feds_notebook.livemd)

## Features

* Easily find information on National Research and Education organisation (NREN) federations.
* Filter and group federations by location, type, structure and tags.
* Use federation records directly with Smee to download metadata from aggregates or MDQ servers
* Export lists of federation information as CSV, JSON or Markdown documents
* Manage and load federation data into your applications
* Includes over 70 research and education federations' details for use in tests

The top level `SmeeFeds` module has tools for selecting individual federation details or lists of many at once.
SmeeFeds contain more tools for handling federations, such as:

* `SmeeFeds.Federation` - tools for accessing data such as metadata download URLs, contacts, homepages, and so on.
* `SmeeFeds.Export` - convert lists of federations into JSON or CSV data for export, or simple text reports
* `SmeeFeds.Import` - convert JSON documents into Federation lists
* `SmeeFeds.Filter` - filter lists of federations by various criteria

## IMPORTANT DISCLAIMER AND WARNING

SmeeFeds comes with a built-in list of federations, using information gathered from various sources on the Internet.

This collection of information is example data for use by **researchers, developers and testers**. 

**IT IS NOT FOR USE IN PRODUCTION ENVIRONMENTS**

Metadata is the bedrock of trust and information security in SAML federations. DO NOT use metadata URLs, certificates 
and certificate fingerprints to download and use metadata in live services without confirming each detail yourself.

If you must use SmeeFeds as part of a production service, then after information has been verified you can export only
the verified information you need as a JSON file and set it as the new default using 
`:smee_feds, :data_file` config setting in your application (if compiled) or set a list of Federations with 
`:smee_feds, :federations` at runtime.

There is absolutely no guarantee or warranty that the data in SmeeFeds is correct, and it is not supported by any of 
the federations listed. It's totally unofficial. 

## Examples

### Using with Smee to download UK Access Management Federation metadata, pick a random entity and get its XML
Useful for testing as there's no need to remember or look up metadata details.

```elixir
random_xml = SmeeFeds.federation(:ukamf)
|> SmeeFeds.Federation.aggregate()
|> Smee.fetch!()
|> Smee.Metadata.random_entity()
|> Smee.Entity.xml()
```

### Finding an MDQ service 
Very few MDQ services are present in the data, but they can be used as follows:

```elixir
cern_idp = SmeeFeds.federation(:incommon)
|> SmeeFeds.Federation.mdq()
|> Smee.MDQ.lookup!("https://cern.ch/login")
```

You can list the IDs of all federations that have an MDQ service using a filter:

```elixir
SmeeFeds.federations()
|> SmeeFeds.Filter.mdq()
|> SmeeFeds.ids()
```

### Getting a list of specific federations and writing their details to disk as a JSON file or CSV
The JSON file can be used a new default set of federations. 

```elixir
SmeeFeds.federations([:wayf, :haka, :dfnaai, :swamid])
|> SmeeFeds.Export.json_file!("my_feds.json")
```

The CSV export is a simpler, lossy summary.
```elixir
csv = SmeeFeds.federations([:wayf, :haka, :dfnaai, :swamid])
       |> SmeeFeds.Export.csv()

File.write!("my_feds.csv", csv)
```

### Defining your own lists of federations

```elixir
my_feds = [
SmeeFeds.Federation.new(:fed1, name: "Example 1", sources: [Smee.Source.new("https://example.com/metadata")]),
SmeeFeds.Federation.new(:fed2, name: "Example 2", sources: [Smee.Source.new("https://example.edu/metadata")])
] 
 ```

### Filtering lists of federations

Listing all known federations, then selecting those in the EU, and listing their unique IDs

```elixir
SmeeFeds.federations()
|> SmeeFeds.Filter.eu()
|> SmeeFeds.ids()
```

Finding all hub-and-spoke networks with an MDQ service and returning their names

```elixir
SmeeFeds.federations()
|> SmeeFeds.Filter.structure(:has)
|> SmeeFeds.Filter.mdq()
|> Enum.map(fn f -> f.name end)


```

### Opening all homepages 

Perhaps you want to check the homepages of all federations in a collection (this example works on a Mac)

```elixir
SmeeFeds.federations()
|> Enum.each(fn f -> if f.url, do: System.cmd("open", [f.url]) end)
```

Or see all logos

```elixir
SmeeFeds.federations()
|> Enum.each(fn f -> if f.logo, do: System.cmd("open", [f.logo]) end)
```

### Information about lists of federations

The top level SmeeFeds module can return unique values present in collections. For example, all tags:

```elixir
tags = SmeeFeds.federations()
|> SmeeFeds.tags()
```

or structure types

```elixir
structures = SmeeFeds.federations()
|> SmeeFeds.structures()
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `smee_feds` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:smee_feds, "~> 0.3.1"}
  ]
end
```

SmeeFeds requires [Smee](https://github.com/Digital-Identity-Labs/smee), which has its own unusual requirements, so
please make sure you read the documentation for installing Smee before using SmeeFeds.

## Uses

The main reason SmeeFeds was hurriedly put together on a Sunday afternoon is that I needed to test `Smee` with a variety
of federations, and my various scattered notes and comments and tests with URLs and certificate fingerprints were becoming a nuisance.
The original focus was on the default data, as a convenient resource for testing.

It's possibly an over-engineered solution to that problem but it was fun.

Over time the federation collection features of SmeeFeds have become useful in other projects as a way to load sources
of metadata in a consistent way, so these have been expanded and strengthened. 

## Alternatives and Sources

The best source of this information is the websites of the federations themselves, and the best way to find those
websites is to read the websites of Edugain and REFEDS.

* [Edugain](https://edugain.org/) "eduGAIN comprises over 80 participant federations connecting more than 8,000 Identity and Service Providers" 
* [REFEDS](https://refeds.org/) "REFEDS is a community of practitioners actively engaged in access and identity work within their home countries and supportive of standards-compliant developments to enhance international collaboration"
* [MET](https://met.refeds.org/) "Metadata explorer tool is a fast way to find federations, entities, and their relations through entity/federation metadata file information."

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/smee_feds>.

## Contributing

You can request new features by creating an [issue](https://github.com/Digital-Identity-Labs/smee_feds/issues),
or submit a [pull request](https://github.com/Digital-Identity-Labs/smee_feds/pulls) with your contribution.

If you are comfortable working with Python but Smee's Elixir code is unfamiliar then this blog post may help: 
[Elixir For Humans Who Know Python](https://hibox.live/elixir-for-humans-who-know-python)

## Copyright and License

Copyright (c) 2023, 2024 Digital Identity Ltd, UK

SmeeFeds is Apache 2.0 licensed.

## Disclaimer
Smee is not endorsed by The Shibboleth Foundation or any of the NREN's described within.
The API will definitely change considerably in the first few releases after 0.1.0 - it is not stable!
