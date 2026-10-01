version = 3

ScenarioInfo = {
    name = 'Operation Twin Spear',
    description = 'Two UEF commanders deploy behind Cybran lines to sabotage a forward military complex before a larger offensive can begin.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    map_version = 1,
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
