local Attacks = {
    {
        x = INITIAL_X,
        y = INITIAL_Y,
        width = 250,
        height = 25,
        type = 1,
        movement = "vertical",
    },
    {
        x = INITIAL_X,
        y = INITIAL_Y + 25,
        width = 25,
        height = 250,
        type = 2,
        movement = "horizontal",
    },
    {
        x = INITIAL_X + 500,
        y = INITIAL_Y,
        width = 25,
        height = 250,
        type = 3,
        movement = "horizontal-reverse",
    },
    {
        x = INITIAL_X + 25,
        y = INITIAL_Y + 500,
        width = 250,
        height = 25,
        type = 4,
        movement = "vertical-reverse",
    }
}

return Attacks