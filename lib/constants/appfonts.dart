import 'package:flutter/material.dart';
import 'package:cornext_mobile/constants/appcolors.dart';

class AppFonts {
  TextStyle getTextStyle(String _key) {
    TextStyle textStyle;
    switch (_key) {
      case 'cart_badge_content_color':
        textStyle = TextStyle(color: Colors.white);
        break;
      case 'appbar_username':
        textStyle = TextStyle(fontSize: 15);
        break;
      case 'appbar_username_circle':
        textStyle = TextStyle(
            color: mainAppColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'button_text_color_white':
        textStyle = TextStyle(color: Colors.white, fontFamily: 'Raleway_bold');
        break;
      case 'button_text_color_black':
        textStyle = TextStyle(
            color: Colors.black, fontSize: 14, fontFamily: 'Raleway_bold');
        break;
      case 'error_notifications_text_style':
        textStyle = TextStyle(
          color: Colors.red,
        );
        break;
      case 'success_notifications_text_style':
        textStyle = TextStyle(
          color: mainAppColor,
        );
        break;
      case 'delivery_address_delete_info_popup_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: mainAppColor,
            fontFamily: 'Raleway_bold');
        break;
      case 'delivery_address_delete_info_popup_content_style':
        textStyle = TextStyle(fontSize: 18);
        break;
      case 'delivery_address_address_info_content_style':
        textStyle = TextStyle(fontSize: 16);
        break;
      case 'delivery_address_heading_style':
        textStyle = TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'edit_&_new_address_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'state_dropdown_names_style':
        textStyle = TextStyle(
            fontSize: 15.0, color: Colors.black, fontFamily: 'Raleway');
        break;
      case 'state_not_selected_error_styles':
        textStyle = TextStyle(color: Colors.red[700], fontSize: 13);
        break;
      case 'cart_screen_product_name_default_style':
        textStyle = TextStyle(
            fontWeight: FontWeight.w700,
            color: mainAppColor,
            fontSize: 16,
            fontFamily: 'Raleway_bold');
        break;
      case 'cart_screen_brandname_style':
        textStyle = TextStyle(color: orangeColor);
        break;
      case 'cart_screen_specification_&_type_names_styles':
        textStyle = TextStyle(
            color: Colors.black, fontWeight: FontWeight.normal, fontSize: 15);
        break;
      case 'cart_screen_product_price_styles':
        textStyle = TextStyle(
            // color: orangeColor,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            fontFamily: 'Raleway_bold');
        break;
      case 'hide_error_messages_for_formfields':
        textStyle = TextStyle(height: 0);
        break;
      case 'cart_screen_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'browse_for_products_link_style':
        textStyle = TextStyle(color: Colors.blue, fontSize: 18);
        break;
      case 'cart_empty_styles':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'cart_screen_total_amount_style':
        textStyle = TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'cart_screen_button_text_styles':
        textStyle = TextStyle(
            color: Colors.black, fontSize: 15, fontFamily: 'Raleway_bold');
        break;
      case 'no_internet_error_screen_style':
        textStyle = TextStyle(fontSize: 20, color: Colors.red);
        break;
      case 'ordercreationfailed_screen_payment_success_style':
        textStyle = TextStyle(fontSize: 22, color: mainAppColor);
        break;
      case 'ordercreationfailed_screen_error_text_style':
        textStyle = TextStyle(color: Colors.red, fontSize: 18);
        break;
      case 'farm_details_check_box_text_style':
        textStyle = TextStyle(fontSize: 16);
        break;
      case 'farm_details_subcategories_check_box_text_style':
        textStyle = TextStyle(fontSize: 14);
        break;
      case 'skip_link_style':
        textStyle = TextStyle(color: Colors.blue, fontSize: 16);
        break;
      case 'farm_details_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'farm_details_noanimals_check_style':
        textStyle = TextStyle(
          fontSize: 16,
        );
        break;
      case 'feedback_screen_camera_options_text_style':
        textStyle =
            TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Raleway_bold');
        break;
      case 'feedback_screen_total_amount_text_style':
        textStyle = TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Raleway_bold');
        break;
      case 'text_color_black_style':
        textStyle = TextStyle(color: Colors.black, fontFamily: 'Raleway');
        break;
      case 'quantity_field_heading_text_style':
        textStyle = TextStyle(fontWeight: FontWeight.w300);
        break;
      case 'quantity_value_text_style':
        textStyle =
            TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Raleway_bold');
        break;
      case 'feedback_screen_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'purchased_products_text_style_in_all_screens':
        textStyle = TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'order_deatils_display_styles_for_list_view':
        textStyle = TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Raleway_bold'
            // color: orangeColor
            );
        break;
      case 'feedback_screen_total_amount_value_styles':
        textStyle = TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold',
            fontSize: 16,
            color: orangeColor);
        break;
      case 'feedback_screen_feedback_field_text_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'forgot_passwords_screen_heading_styles':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'home_screen_repeat_previous_order_popup_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold',
            color: mainAppColor);
        break;
      case 'home_screen_repeat_previous_order_popup_content_style':
        textStyle = TextStyle(fontSize: 18);
        break;
      case 'home_screen_repeat_previous_order_button_style':
        textStyle = TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: 'Raleway_bold');
        break;
      case 'offer_details_screen_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'offer_details_screen_content_heading_style':
        textStyle = TextStyle(
            letterSpacing: 0.5,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'offer_details_scren_content_style':
        textStyle =
            TextStyle(fontSize: 15, wordSpacing: 1.5, color: Colors.black);
        break;
      case 'order_confirmation_screen_message_style':
        textStyle = TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            fontFamily: 'Raleway_bold');
        break;
      case 'order_confirmation_screen_light_color_message':
        textStyle = TextStyle(fontWeight: FontWeight.w300);
        break;
      case 'order_conirmation_screen_headings_style':
        textStyle = TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Raleway_bold');
        break;
      case 'order_summary_screen_devilery_address_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Raleway_bold');
        break;
      case 'order_summary_screen_delivery_address_contnet_style':
        textStyle = TextStyle(fontSize: 16);
        break;
      case 'order_summary_headings_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Raleway_bold');
        break;
      case 'text_color_red_style':
        textStyle = TextStyle(color: Colors.red);
        break;
      case 'text_color_mainappcolor_style':
        textStyle = TextStyle(color: mainAppColor);
        break;
      case 'ordersummary_total_amount_labels_heading_style':
        textStyle = TextStyle(fontWeight: FontWeight.w300);
        break;
      case 'ordersummary_total_amount_heading_style':
        textStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w300);
        break;
      case 'ordersummary_total_amount_content_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'ordersummary_total_discount_content_style':
        textStyle = TextStyle(fontStyle: FontStyle.italic, color: mainAppColor);
        break;
      case 'product_details_screen_product_name_default_styles':
        textStyle = TextStyle(
            fontWeight: FontWeight.w700,
            color: mainAppColor,
            fontSize: 20,
            fontFamily: 'Raleway_bold');
        break;
      case 'product_details_screen_product_specification_styles':
        textStyle = TextStyle(color: Colors.black, fontSize: 16);
        break;
      case 'product_details_price_style':
        textStyle = TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold',
            fontSize: 20.0);
        break;
      case 'product_details_orginal_price_heading_style':
        textStyle = TextStyle(
            // fontWeight: FontWeight.bold,
            fontSize: 15);
        break;
      case 'product_details_orginal_price_style':
        textStyle = TextStyle(
            decoration: TextDecoration.lineThrough,
            // fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            fontSize: 15);
        break;
      case 'product_details_discount_amount_style':
        textStyle = TextStyle(
            fontStyle: FontStyle.italic, fontSize: 15, color: orangeColor);
        break;
      case 'product_details_discount_amount_note_message_style':
        textStyle = TextStyle(color: orangeColor, fontSize: 14);
        break;
      case 'product_details_product_info_headings_style':
        textStyle = TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold);
        break;
      case 'product_details_headings_style':
        textStyle = TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'product_listview_size_style':
        textStyle = TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        );
        break;
      case 'homescreen_categories_name_style':
        textStyle = TextStyle(
          fontSize: 12.0,
        );
        break;
      case 'hint_style':
        textStyle = TextStyle(
          fontSize: 14.0,
        );
        break;
      case 'internal_headers_style':
        textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
        break;
      case 'product_details_content_styles':
        textStyle = TextStyle(
          height: 1.5,
        );
        break;
      case 'order_details_screen_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Raleway_bold');
        break;
      case 'order_details_main_headings_style':
        textStyle = TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            fontFamily: 'Raleway_bold');
        break;
      case 'order_details_sub_headings_style':
        textStyle = TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            fontFamily: 'Raleway_bold');
        break;
      case 'order_details_total_amount_heading_style':
        textStyle = TextStyle(fontSize: 18);
        break;
      case 'order_details_amount_values_style':
        textStyle =
            TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Raleway_bold');
        break;
      case 'order_details_payment_detail_values_style':
        textStyle =
            TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Raleway_bold');
        break;
      case 'order_list_sub_headings_style':
        textStyle = TextStyle(
          fontSize: 16,
          // fontWeight: FontWeight.bold,
          // color: mainAppColor
        );
        break;
      case 'order_list_main_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold'
            // decoration: TextDecoration.underline,

            // color: Colors.white,
            );
        break;
      case 'no_recent_orders_text_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Raleway_bold');
        break;
      case 'otp_validation_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'product_list_row_brand_name_style':
        textStyle = TextStyle(
            fontWeight: FontWeight.w700,
            color: orangeColor,
            fontSize: 15,
            letterSpacing: 0.6,
            fontFamily: 'Raleway_bold');
        break;
      case 'product_list_row_product_name_style':
        textStyle = TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 15,
            fontFamily: 'RaleWay_bold');
        break;
      case 'product_list_size_and_price_fields_styles':
        textStyle = TextStyle(fontSize: 13.0, color: Colors.grey);
        break;
      case 'product_list_orginal_price_style':
        textStyle = TextStyle(
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.lineThrough,
            // fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 14.0);
        break;
      case 'product_list_price_style':
        textStyle = TextStyle(
            fontSize: 15.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'product_list_price_style_label':
        textStyle = TextStyle(
          color: Colors.black,
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
        );
        break;
      case 'product_list_discount_price_style':
        textStyle = TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Raleway_bold');
        break;
      case 'product_list_discount_value_style':
        textStyle = TextStyle(
            fontSize: 13.0,
            // fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.black);
        break;
      case 'product_list_tile_product_name_style':
        textStyle = TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: orangeColor,
            // height: 1
            fontFamily: 'Raleway_bold');
        break;
      case 'subscription_confirmation_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'subscription_confirmation_sub_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'subscription_confirmation_skip_link_style':
        textStyle = TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Raleway_bold',
          color: Colors.lightBlueAccent,
          decoration: TextDecoration.underline,
        );
        break;
      case 'subscription_list_sub_headings_style':
        textStyle = TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Raleway_bold');
        break;
      case 'subscription_list_no_subscriptions_found':
        textStyle = TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Raleway_bold');
        break;
      case 'subscription_list_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold'
            // color: Colors.white,
            );
        break;
      case 'edit_subscription_cancle_popup_heading_style':
        textStyle = TextStyle(
          fontSize: 18,
        );
        break;
      case 'edit_subscription_heading_style':
        textStyle = TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'edit_subscription_total_amount_heading_style':
        textStyle = TextStyle(
          fontSize: 20,
        );
        break;
      case 'edit_subscription_total_amount_value_style':
        textStyle = TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            fontFamily: 'Raleway_bold');
        break;
      case 'cart_units_text_style':
        textStyle = TextStyle(fontSize: 15.0);
        break;
      case 'edit_profile_customer_id_heading_style':
        textStyle = TextStyle(
            color: Colors.black, fontSize: 18, fontFamily: 'Raleway_bold');
        break;
      case 'edit_profile_customer_id_value_style':
        textStyle = TextStyle(
            // fontStyle:
            //     FontStyle.italic,
            // fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFamily: 'Raleway_bold');
        break;
      case 'registration_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold');
        break;
      case 'text_color_black_with_font_family':
        textStyle = TextStyle(color: Colors.black, fontFamily: 'Raleway');
        break;
      case 'product_list_tile_view_offer_price_heading_style':
        textStyle = TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'Raleway_bold');
        break;
      case 'add_font_family_rale_way_bold':
        textStyle = TextStyle(
          fontFamily: 'Raleway_bold',
        );
        break;
      case 'faq_heading_style':
        textStyle = TextStyle(
            fontFamily: 'Raleway_bold',
            fontSize: 17,
            fontWeight: FontWeight.bold);
        break;
      case 'faq_sub_heading_with_red_color':
        textStyle = TextStyle(
            fontFamily: 'Raleway_bold',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.red);
        break;
      case 'faq_sub_heading':
        textStyle = TextStyle(
          fontFamily: 'Raleway_bold',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'faq_content_style':
        textStyle = TextStyle(fontSize: 14, height: 1.4);
        break;
      case 'app_update_heading_style':
        textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway_bold',
            color: mainAppColor);
        break;
      case 'app_update_content_style':
        textStyle = TextStyle(fontSize: 16);
        break;
      default:
        textStyle = TextStyle();
    }
    return textStyle;
  }
}
