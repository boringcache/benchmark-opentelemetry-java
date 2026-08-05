# BoringCache OpenTelemetry Java benchmark

This repository contains the BoringCache benchmark for OpenTelemetry Java.

Benchmark workflows are in [`.github/workflows/`](.github/workflows/), with configuration in [`.boringcache.toml`](.boringcache.toml).

The workflows run the pinned upstream project with its native Gradle build on
fresh runners. `boringcache/one` owns cache setup, restore, save, and evidence;
this repository retains the product evidence without reimplementing its
correctness contract.
