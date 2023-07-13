# 0.1.0

- Requires dart 3.
- Added the option to specify which Earth radius should be used when calculating Haversine distance
  in [withinGeographicalRadius].
- Tidied up the code style to better match typical dart code style.
- Removed some unnecessary internal generic types.

# 0.0.5

- Stop storing provided points as they are not used by this package and can be stored by the
  calling code if required.

# 0.0.4

- Add withinGeographicalRadius for calculating points within x kilometers from a given latitude and
  longitude.

# 0.0.3

- Add a length getter

# 0.0.2

- Store and make points accessible.

# 0.0.1+1

- Add missing braces for linter.

## 0.0.1

- Initial version.
