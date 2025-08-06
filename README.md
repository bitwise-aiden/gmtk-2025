# GMTK 2025

Theme: Loop


### Level data layout

```
2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2,
2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 2,
2, 0, 1, 6, 1, 0, 1, 7, 1, 0, 2,
2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 2,
2, 0, 1, 4, 1, 5, 1, 4, 1, 0, 2,
2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 2,
2, 0, 1, 7, 1, 0, 1, 6, 1, 0, 2,
2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 2,
2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2,
2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
;7,5:5,5/3,5:5,5
;0
;0
```

- Levels, separated by `~`.
- Data, separated by `;`.
- Whitespace is removed before parsing, so formatting as 11 rows of 11 values is to make it easier to deal with raw data.
- Separated data is orderd as such:
    - 0: Level data
        - Must be 11x11 with values from 0 - 9 (inclusive)
    - 1: Cel data, separated by `/`, each have:
        - Header of coord to which cel it is for.
        - Context aware based on the type from level data.
            - Button separated by `|`:
                - 0: Inverted or not
                - 1+: Coords for targets that will be triggered
    - 2: Best instruction count
    - 3: Best move count
