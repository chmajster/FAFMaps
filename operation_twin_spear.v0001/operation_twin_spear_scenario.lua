version = 3

ScenarioInfo = {
    name = 'Operation Twin Spear',
    description = 'Two UEF commanders establish a southern foothold, cross a contested river and break a Cybran forward command outpost before the enemy can reinforce the sector.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    map_version = 2,
    size = {1024, 1024},
    norushradius = 0,

    map = '/maps/operation_twin_spear.v0001/operation_twin_spear.scmap',
    save = '/maps/operation_twin_spear.v0001/operation_twin_spear_save.lua',
    script = '/maps/operation_twin_spear.v0001/operation_twin_spear_script.lua',

    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {
                        'Player1',
                        'CybranMain',
                        'CybranOutpost',
                        'Neutral',
                        'Player2',
                    },
                },
            },
            customprops = {},
            factions = {
                {'uef'},
                {'uef'},
            },
        },
    },
}
