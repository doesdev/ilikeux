(function ($, window, document) {

    var pluginName = "jqueryFunWithBoxes",
        defaults = {
            boxes_x: 10,
            boxes_y: 10,
            spacing: 6,
            rounded: 4,
            border_size: 1,
            border_color: "#000",
            border_same_as_fill: 0,
            fill_colors: "#fff",
            fill_opacity: 1,
            animation_time: 0
        };

    function FunWithBoxes(element, options) {
        this.element = element;
        this.base_settings = $.extend({}, defaults, options);
        this.init();
    }

    FunWithBoxes.prototype = {
        init: function () {

            var settings = this.base_settings;
            function createBoxes() {
                $(this.boxBuilder());
            }

            if (settings.animation_time > 0) {
                window.setInterval($.proxy(createBoxes, this), settings.animation_time);
            }

            $(window).on('resize', $.proxy(createBoxes, this));
            $(document).ready($.proxy(createBoxes, this));
        },

        boxBuilder: function () {
            var settings, wrapper, boxes, i;
            settings = this.base_settings;
            wrapper = $(this.element);
            wrapper.empty();
            boxes = [];
            for (i = 0; i < (settings.boxes_x * settings.boxes_y); i =  i + 1) {
                boxes.push('<div class="box box-' + i + '"></div>');
            }
            this.applyStyling();
            wrapper.append(boxes.join(''));
            this.boxColors();
        },

        boxColors: function () {
            var settings, colors, color, border;
            settings = this.base_settings;
            colors = $.makeArray(settings.fill_colors);
            if (colors.length === 1) {
                color = colors[0];
                border = (settings.border_same_as_fill === 1) ? color : settings.border_color;
                $('.box').css({
                    'background-color': this.colorConverter(color),
                    'border': settings.border_size + 'px solid ' + this.fullHex(border)
                });
            } else {
                $.each($('.box'),
                    $.proxy(function (i, obj) {
                        color = colors[this.randomNumber(0, colors.length)];
                        border = (settings.border_same_as_fill === 1) ? color : settings.border_color;
                        $(obj).css({
                            'background-color': this.colorConverter(color),
                            'border': settings.border_size + 'px solid ' + this.fullHex(border)
                        });
                    }, this)
                    );
            }
        },

        applyStyling: function () {
            var settings, style_tag, styles, wrapper, boxes_id_class, box_width, box_height;
            settings = this.base_settings;
            wrapper = $(this.element);
            boxes_id_class = (wrapper.attr('id') === undefined) ? "." + wrapper.attr('class') : "#" + wrapper.attr('id');
            $('#boxes-style').remove();
            style_tag = $('<style type="text/css" id="boxes-style">').appendTo($('head'));
            box_width = wrapper.outerWidth() / settings.boxes_x - ((settings.spacing + settings.border_size) * 2);
            box_height = wrapper.outerHeight() / settings.boxes_y - ((settings.spacing + settings.border_size) * 2);

            styles = boxes_id_class + '{ ' +
                'padding: 0; ' +
                'overflow: hidden; ' +
                '} ' +
                '.box{ ' +
                'position: relative; ' +
                'float: left; ' +
                'width: ' + box_width + 'px; ' +
                'height: ' + box_height + 'px; ' +
                'margin: ' + settings.spacing + 'px; ' +
                'border-radius: ' + settings.rounded + 'px;';

            style_tag.html(styles);

        },

        randomNumber: function (from, to) {
            return Math.floor(Math.random() * (to - from) + from);
        },

        colorConverter: function (hex) {
            var red, blue, green, opacity;
            opacity = this.base_settings.fill_opacity;
            red = parseInt((this.prepHex(hex)).substring(0, 2), 16);
            blue = parseInt((this.prepHex(hex)).substring(2, 4), 16);
            green = parseInt((this.prepHex(hex)).substring(4, 6), 16);
            return 'rgba(' + red + ', ' + blue + ', ' + green + ', ' + opacity + ')';
        },

        prepHex: function (hex) {
            hex = (hex.charAt(0) === "#") ? hex.split("#")[1] : hex;
            if (hex.length === 3) {
                hex = hex + hex;
            }
            return hex;
        },

        fullHex: function (hex) {
            hex = "#" + this.prepHex(hex);
            return hex;
        },

        destroy: function () {
            $(this).off();
            $(this).removeData();
        }
    };

    $.fn[pluginName] = function (options) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName, new FunWithBoxes(this, options));
            }
        });
    };

    return this;

})(jQuery, window, document);