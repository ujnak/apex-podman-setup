/*!
 * Copyright (c) 2015, 2025, Oracle and/or its affiliates.
 */
( function( $, apex ) {
    "use strict";

    var VALUE_VARIES = {};

    const hasOwnProperty = apex.util.hasOwnProperty;

    apex.templateOptionsHelper = {
        getValuesFromDialog: function( properties, dialog$ ) {
            let lValues = [];
            function addValues( pProperties ) {
                for ( let i = 0; i < pProperties.length; i++ ) {
                    let lValue = dialog$.propertyEditor( "getPropertyValue", pProperties[ i ].propertyName );
                    if ( !$.isEmptyObject( lValue ) ) {
                        lValues.push( lValue );
                    }
                }
            }
            // Get selected template options from all our properties
            addValues( properties.common );
            addValues( properties.advanced );
            return lValues;
        },
        getProperties: function( templateOptions, lValues, readOnly, prop ) {
            let i,
                lGroupId,
                lGroupIdx,
                lGroup,
                lDisplayGroupId,
                lTemplateOptionsVal,
                lGroups           = [],
                lGroupsMap        = {},
                lGeneralValues    = [],
                lGeneralLovValues = [],
                lGroupValue       = {},
                lProperties       = {
                    common:   [],
                    advanced: []
                },
                // Multi-select support
                joinedGeneralValues,
                lMetaData,
                lPropertyId = '',
                isMultiSelected,
                hasMultiSelectedData;

            if ( prop ) {

                lPropertyId      = prop.propertyName;
                isMultiSelected  = $.isEmptyObject( prop.value );

                if ( prop.metaData && prop.metaData.multiSelectData ) {
                    hasMultiSelectedData = true;
                } else {
                    hasMultiSelectedData = false;
                }

            }

            // Build a list of "general" template options and one for each group
            for ( i = 0; i < templateOptions.values.length; i++ ) {

                lTemplateOptionsVal = templateOptions.values[ i ];

                if ( lTemplateOptionsVal.groupId ) {

                    lGroupId = lTemplateOptionsVal.groupId;

                    if ( !hasOwnProperty( lGroupsMap, lGroupId )) {

                        lGroup = templateOptions.groups[ lGroupId ];

                        lGroups.push({
                            title:      lGroup.title,
                            seq:        lGroup.seq,
                            nullText:   lGroup.nullText,
                            isAdvanced: lGroup.isAdvanced,
                            isRequired: false,
                            lovValues:  [],
                            value:      ""
                        });
                        lGroupIdx = lGroups.length - 1;
                        lGroupsMap[ lGroupId ] = lGroupIdx;
                    } else {
                        lGroupIdx = lGroupsMap[ lGroupId ];
                    }

                    if ( templateOptions.presetValues.includes( lTemplateOptionsVal.r ) ) {
                        if ( lGroups[ lGroupIdx ].value === "" ) {
                            lGroups[ lGroupIdx ].value = lTemplateOptionsVal.r;
                        }

                        // Bug 37021932 and 37564624
                        // 1. if null text exists, always show it in the group
                        // 2. if null text doesn't exist
                        //    if there's a default template option (preset), don't show the null option
                        //    if there's no default template option (preset), show - Select -
                        if ( !lGroup.nullText ) {
                            lGroups[ lGroupIdx ].isRequired = true;
                        }
                    }

                    // Set the current selection for that group
                    if ( lValues.includes( lTemplateOptionsVal.r ) ) {
                        lGroups[ lGroupIdx ].value = lTemplateOptionsVal.r;
                    }
                    lGroups[ lGroupIdx ].lovValues.push({
                        r: lTemplateOptionsVal.r,
                        d: lTemplateOptionsVal.d
                    });

                } else {

                    lGeneralLovValues.push( lTemplateOptionsVal );

                    // Is the LOV value one of our selected values?
                    if ( lValues.includes( lTemplateOptionsVal.r ) ) {
                        lGeneralValues.push( lTemplateOptionsVal.r );
                    }

                }
            }

            joinedGeneralValues = isMultiSelected ? VALUE_VARIES : lGeneralValues.join( ":" );

            // Sort result based on sequence and if they are equal, use title as second sort option
            lGroups.sort( function( a, b ) {
                if ( a.seq === b.seq ) {
                    return a.title.localeCompare( b.title );
                } else {
                    return a.seq - b.seq;
                }
            });

            // There is always a "General" property, because we will at least have a #DEFAULT# entry

            lMetaData = {
                type:                   "TEMPLATE OPTIONS GENERAL",
                prompt:                 apex.lang.getMessage("TEMPLATE_OPTIONS.GENERAL"),
                isReadOnly:             !!readOnly,
                isRequired:             false,
                lovValues:              lGeneralLovValues,
                displayGroupId:         "common",
                defaultTemplateOptions: templateOptions.defaultValues
            };
            // Store multi selected data if any.
            if ( hasMultiSelectedData ) {
                lMetaData.multiSelectData = prop.metaData.multiSelectData;
            }

            lProperties.common[ 0 ] = {
                propertyName:   "general",
                propertyId:     lPropertyId,
                value:          joinedGeneralValues,
                oldValue:       joinedGeneralValues,
                originalValue:  joinedGeneralValues,
                metaData:       lMetaData,
                errors:         [],
                warnings:       []
            };

            // Add a select list for each template options group
            for ( i = 0; i < lGroups.length; i++ ) {

                lGroup          = lGroups[ i ];
                lDisplayGroupId = lGroup.isAdvanced ? 'advanced' : 'common';
                lGroupValue     = lGroup.value ? lGroup.value : '';

                lMetaData = {
                    type:           $.apex.propertyEditor.PROP_TYPE.SELECT_LIST,
                    prompt:         lGroup.title,
                    isReadOnly:     !!readOnly,
                    isRequired:     lGroup.isRequired,
                    nullText:       lGroup.nullText,
                    lovValues:      lGroup.lovValues,
                    displayGroupId: lDisplayGroupId
                };

                if ( hasMultiSelectedData ) {
                    lMetaData.multiSelectData = prop.metaData.multiSelectData;
                }

                lProperties[ lDisplayGroupId ].push({
                    propertyName:   "grp" + i,
                    value:          lGroupValue,
                    oldValue:       lGroupValue,
                    originalValue:  lGroupValue,
                    metaData:       lMetaData,
                    errors:         [],
                    warnings:       []
                });
            }

            return lProperties;
        },
        addGeneralPropertyType: function () {
            $.apex.propertyEditor.addPropertyType( "TEMPLATE OPTIONS GENERAL", {
                init: function( pElement$, prop ) {
                    let lDefaultCheckboxes$ = $();

                    function _setDefaultOptions( ) {

                        let lChecked = $( this ).prop( "checked" );

                        if ( lChecked ) {
                            lDefaultCheckboxes$.prop( "checked", true );
                        }

                        lDefaultCheckboxes$.prop( "disabled", lChecked );

                    }

                    // call base checkboxes
                    this.super( "init", pElement$, prop );

                    let checkboxes$      = pElement$.find( "input[type=checkbox]" );
                    let defaultCheckbox$ = checkboxes$.filter( "[value='#DEFAULT#']" );

                    // Get all default template options checkboxes
                    for ( let i = 0; i < prop.metaData.defaultTemplateOptions.length; i++ ) {
                        lDefaultCheckboxes$ =
                            lDefaultCheckboxes$.add(
                                checkboxes$.filter(
                                    "[value='" +
                                    apex.util.escapeCSS(
                                        prop.metaData.defaultTemplateOptions[ i ]) + "']" ));
                    }

                    defaultCheckbox$
                        .on( "click setdefaultcheckboxes", _setDefaultOptions )
                        .trigger( "setdefaultcheckboxes" );
                },
                getValue: function( pProperty$ ) {
                    let lValues = [];
                    pProperty$.find("input[type=checkbox]").filter( ":checked:not(:disabled)" ).each( function() {
                        lValues.push( this.value );
                    });

                    return lValues.join( ":" );
                },
                setValue: function( pElement$, prop, value ) {
                    this.super( "setValue", pElement$, prop, value );
                    pElement$.find( "input[type=checkbox]" ).filter( "[value='#DEFAULT#']").trigger( "setdefaultcheckboxes" );
                }

            }, "CHECKBOXES" );
        }
    };
})( apex.jQuery, apex );