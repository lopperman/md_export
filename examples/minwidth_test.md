# Minimum Width Test

This tests columns with non-wrappable content.

## Problem Case: Short header, long non-wrapping content

| ID | Code | Configuration | Notes |
|----|------|---------------|-------|
| 1 | ABC123XYZ789 | default_config_name | This is a long note that should wrap nicely across multiple lines. |
| 2 | LONGCODEHERE | alternate_mode | Another long description with lots of text that wraps. |
| 3 | XY | very_long_configuration_identifier | Short note. |

## Problem Case: Dates and numbers

| # | Date | Amount | Description |
|---|------|--------|-------------|
| 1 | 2024-01-15 | $1,234,567.89 | Payment received for services rendered during the previous quarter. |
| 2 | 2024-12-31 | $999.00 | Small payment. |

## Problem Case: URLs in narrow column

| Type | URL | Status |
|------|-----|--------|
| API | https://api.example.com/v1 | Active |
| Web | https://www.verylongdomainname.com/path/to/resource | Inactive |
