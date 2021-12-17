import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/services/productsearchandfilterservice/productsearchandfilterservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

class FaqsPage extends StatefulWidget {
  @override
  FaqsScreen createState() => FaqsScreen();
}

class FaqsScreen extends State<FaqsPage> {
  // Map OfferDescription = {};
  final scaffoldkey = GlobalKey<ScaffoldState>();
  final searchFieldController = TextEditingController();
  final searchFieldKey = GlobalKey<FormFieldState>();
  final searchFocusNode = FocusNode();
  final AppFonts appFonts = AppFonts();
  final List faqsObject = [
    {
      'heading': 'FAQS',
      'questionsAndAnswers': [],
      'content':
          'To  help our customers who may not be very familiar with the functioning of FeedNext App we are providing with most Frequently Asked Questions below. If your query is of urgent nature and is different from the set of questions mentioned below, then do write to us at support@feednext.in or call us on 1800-121-7677 between 8 am & 8 pm on all days including Sunday to get our immediate help.'
    },
    {
      'heading': 'REGISTRATION',
      'questionsAndAnswers': [
        {
          'question': 'How do I register?',
          'answer':
              'You can register by clicking the Menu icon at the top left corner of the homepage, choose the "Register/Sign In" option. Click on “New Customer?”. Please provide the information in the form that appears. You can review the terms and conditions, provide your payment mode details and submit the registration information.',
        },
        {
          'question': 'Are there any charges for registration?',
          'answer': 'No. Registration on feednext.in is absolutely free.',
        },
        {
          'question': 'Do I have to necessarily register to shop on feednext?',
          'answer':
              'You can surf and add products to the cart without registration but only registered shoppers will be able to checkout and place orders. Registered members have to be logged in at the time of checking out the cart, they will be prompted to do so if they are not logged in.',
        },
        {
          'question': 'Can I have multiple registrations?',
          'answer':
              'Each email address and contact phone number can only be associated with one FeedNext account.',
        },
        {
          'question': 'Can I add more than one delivery address in an account?',
          'answer':
              'Yes, you can add multiple delivery addresses in your FeedNext account. However, remember that all items placed in a single order can only be delivered to one address. If you want different products delivered to different addresses you need to place them as separate orders.',
        },
        {
          'question':
              'Can I have multiple accounts with the same mobile number and email id?',
          'answer':
              'Each email address and phone number can be associated with one FeedNext account only.',
        },
        {
          'question':
              'Can I have multiple accounts for members in my family with different mobile numbers and email address but same or common delivery address?',
          'answer':
              'Yes, we do understand the importance of time and the toil involved in shopping groceries. Up to three members in a family can have the same address provided the email address and phone number associated with the accounts are unique.',
        },
        {
          'question':
              'Can I have different city addresses under one account and still place orders for multiple cities?',
          'answer': 'Yes, you can place orders for multiple cities.'
        },
      ],
    },
    {
      'heading': 'ACCOUNT RELATED',
      'questionsAndAnswers': [
        {
          'question': 'What is My Account?',
          'answer':
              'My Account is the section you reach after you log in at feednext.in. My Account allows you to track your active orders, credit note details as well as see your order history and update your contact details.',
        },
        {
          'question': 'How do I reset my password?',
          'answer':
              'You need to enter your phone number on the Login page and click on forgot password. An sms with a reset password will be sent to your mobile phone. With this, you can change your password. In case of any further issues please contact our customer support team.',
        }
      ]
    },
    {
      'heading': 'PAYMENT',
      'questionsAndAnswers': [
        {
          'question': 'What are the modes of payment?',
          'answer':
              "You can pay for your order on feednext.in using the following modes of payment:",
          'textInListView': [
            'a. Netbanking',
            'b. Credit and debit cards (VISA / Mastercard / Rupay)',
            'c. UPI'
          ]
        },
        {
          'question':
              'Are there any other charges or taxes in addition to the price shown? Is VAT added to the invoice?',
          'answer':
              'There is no VAT. However, GST will be applicable as per Government Regulations.',
          'anyOtherColors': 'red'
        },
        {
          'question': 'Is it safe to use my credit/ debit card on feednext?',
          'answer':
              'Yes it is absolutely safe to use your card on feednext.in. A recent directive from RBI makes it mandatory to have an additional authentication pass code verified by VISA (VBV) or MSC (Master Secure Code) which has to be entered by online shoppers while paying online using visa or master credit card. It means extra security for customers, thus making online shopping safer.',
        },
        {
          'question': 'Where do I enter the coupon code?',
          'answer':
              'Once you are done selecting your products and clicking on the checkout you will be prompted to payment method. On the payment method page there is a box where you can enter any evoucher/ coupon code that you have. The amount will automatically be deducted from your invoice value.',
        }
      ]
    },
    {
      'heading': 'DELIVERY RELATED',
      'questionsAndAnswers': [
        {
          'question': 'How will the delivery be done?',
          'answer':
              'We have a dedicated team of delivery personnel and a fleet of vehicles operating across different states which ensures timely and accurate delivery to our customers.',
        },
        {
          'question':
              'How do I change the delivery info (address to which I want products delivered)?',
          'answer':
              'You can change your delivery address on our website once you log into your account. Click on "My Account" at the top right hand corner and go to the "Update My Profile" section to change your delivery address.',
          'anyOtherColors': 'red'
        },
        {
          'question': 'How much are the delivery charges?',
          'answer':
              'Usually the delivery charges are free on most of our products. Depending on availability of stock in your nearest stock point we may charge as per the distance.',
        },
        {
          'question': 'Do you deliver in my area?',
          'answer':
              'You will be able to check this detail at the product page when you enter the pin code.',
        },
        {
          'question':
              'Will someone inform me if my order delivery gets delayed?',
          'answer':
              'In case of a delay, our customer support team will keep you updated about your delivery.',
        },
        {
          'question': 'What is the minimum order for delivery?',
          'answer': 'There is no minimum order for delivery.',
        }
      ]
    },
    {
      'heading': 'ORDER RELATED',
      'questionsAndAnswers': [
        {
          'question': 'How do I add or remove products after placing my order?',
          'answer':
              'Once you have placed your order you will not be able to make modifications on the website. Please contact our customer support team for any modification of order.',
        },
        {
          'question': 'Is it possible to order an item which is out of stock?',
          'answer':
              'No you can only order products which are in stock. We try to ensure availability of all products on our website however due to supply chain issues sometimes this is not possible.',
        },
        {
          'question': 'How do I check the current status of my order?',
          'answer':
              'You can check the status of your order by going to ‘My Orders’. Or call our customer service number 1800-121-7677.',
        },
        {
          'question':
              'How do I check which items were not available from my order? Will someone inform me about the items unavailable in my order before delivery?',
          'answer':
              'You will receive an email as well as an sms about unavailable items before the delivery of your order.',
        },
        {
          'question': 'What You Receive Is What You Pay For.',
          'answer':
              'At the time of delivery, we advise you to kindly check every item as in the invoice. Please report any missing item that is invoiced. As a benefit to our customers, if you are not available at the time of order delivery or you haven’t checked the list at the time of delivery we provide a window of 48hrs to report missing items. This is applicable only for items that are invoiced.',
        },
        {
          'question': 'When and how can I cancel an order?',
          'answer':
              'You can cancel an order by contacting our customer support team.',
        }
      ]
    },
    {
      'heading': 'CUSTOMER RELATED',
      'questionsAndAnswers': [
        {
          'question': 'How do I contact customer service?',
          'answer':
              'Our customer service team is available throughout the week, all seven days from 7 am to 10 pm. They can be reached at 1800-121-7677 or via email at support@feednext.in',
        },
        {
          'question': 'What are your timings to contact customer service?',
          'answer':
              'Our customer service team is available throughout the week, all seven days from 7 am to 10 pm.',
        },
        {
          'question':
              'How can I give feedback on the quality of customer service?',
          'answer':
              'Our customer support team constantly strives to ensure the best shopping experience for all our customers. We would love to hear about your experience with feednext. Do write to us support@feednext.in in case of positive or negative feedback.',
        },
      ]
    },
    {
      'heading': 'RETURN & REFUND',
      'questionsAndAnswers': [
        {
          'question': 'Return - Refund',
          'answer':
              'We have a "no questions asked return and refund policy" which entitles all our members to return the product at the time of delivery if due to some reason they are not sati sfied with the quality or freshness of the product. We will take the returned product back with us and issue a credit note for the value of the return products which will be credited to your account on the Site. This can be used to pay your subsequent shopping bills.',
        },
        {
          'question': 'Return Policy - Time Limits:',
          'answer': 'Within 48 hours from the delivery date',
        },
      ]
    },
    {
      'heading': 'OTHER INFORMATION',
      'questionsAndAnswers': [
        {
          'question': 'Do you have offline stores?',
          'answer':
              'No we are a purely internet based company and do not have any stores.',
        },
        {
          'question':
              'What do I do if an item is defective (broken, leaking, expired)?',
          'answer':
              'In case you are not satisfied with a product received you can return it to the delivery personnel at time of delivery or you can contact our customer support team and we will do the needful.',
        },
        {
          'question':
              'How will I get my money back in case of a cancellation or return?',
          'answer':
              'What are the modes of refund?The amount will be refunded to your feednext.in account to use as store credit in your forthcoming purchases. In case of credit card payments we can also credit the money back to your credit card. The money will be credited back to your account in 7-10 working days.  Please contact customer support for any further assistance regarding this issue.',
        },
        {
          'question':
              'I am a corporate/ business. Can I place orders with feednext.in?',
          'answer':
              'Yes, we do bulk supply of products at special prices to institutions. Please contact as at corporate@feednext.in to know more.',
        },
        {
          'question': "I'd like to suggest some products. Who do I contact?",
          'answer':
              'If you are unable to find a product or brand that you would like to shop for, please write to us at customerservice@feednext.in and we will try our best to make the product available to you.',
        },
        {
          'question': 'How & where I can give my feedback?',
          'answer':
              'We always welcome feedback, both positive and negative from all our customers. Please feel free to write to us at customerservice@feednext.in, or call us on 18001217677 and we will do our best to incorporate your suggestions into our system.',
        },
        {
          'question':
              "The product I want is not available on feednext. How do I get my favorite neighborhood Specialty store listed on feednext?",
          'answer':
              'You can write to sellersupport@feednext.in for all suggestions related to new stores or products. We will work extra hard to get the store listed on FeedNext and get the product available to you.',
        },
        {
          'question':
              'Can I make payment using Sodexo Meal Passes / Ticket Restaurant Meal passes for Specialty orders?',
          'answer':
              'Unfortunately, you cannot pay for Specialty products using meal passes. However, all other modes of payment are accepted as standard such as Cash on Delivery, Card on Delivery, Online payment by Cards/Net Banking/Wallets etc.',
        },
      ]
    }
  ];
  @override
  void initState() {
    // getImage();
    super.initState();
    showOrHideSearchAndFilter = false;
  }

  getSearchedData() {
    if (searchFieldController.text.trim() != '') {
      productSearchData['productSearchData'] =
          searchFieldController.text.trim();
      List filterProductsData = [];
      filterProducts.forEach((val) {
        if (val['isSelected']) {
          Map obj = {'productCategoryId': val['productCategoryId']};
          filterProductsData.add(obj);
        }
      });
      if (filterProductsData.length > 0) {
        productSearchData['productCategoryInfo'] = filterProductsData;
      }
      reset();
      setState(() {
        showOrHideSearchAndFilter = false;
      });
      Navigator.of(context).pushNamed('/search');
    }
  }

  reset() {
    searchFieldController.clear();
    searchFieldKey.currentState?.reset();
  }

  List<Widget> getTextToDisplayInListView(List data) {
    return data.map((textInListView) {
      return Container(
        margin: EdgeInsets.only(
          left: 25,
        ),
        child: Text(textInListView),
      );
    }).toList();
  }

  List<Widget> getFaqSubData(List subFaqData) {
    return subFaqData.map((subTextData) {
      return Container(
          margin: EdgeInsets.only(bottom: 8, top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  child: Text(subTextData['question'],
                      style: subTextData['anyOtherColors'] != null &&
                              subTextData['anyOtherColors'] == 'red'
                          ? appFonts
                              .getTextStyle('faq_sub_heading_with_red_color')
                          : appFonts.getTextStyle('faq_sub_heading'))),
              Container(
                  margin: EdgeInsets.only(top: 1, bottom: 1),
                  child: Text(
                    subTextData['answer'],
                    textAlign: TextAlign.justify,
                    style: appFonts.getTextStyle('faq_content_style'),
                  )),
              subTextData['textInListView'] != null &&
                      subTextData['textInListView'].length > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: getTextToDisplayInListView(
                          subTextData['textInListView']),
                    )
                  : Container()
            ],
          ));
    }).toList();
  }

  List<Widget> getFaqData() {
    return faqsObject.map((text) {
      return Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  child: Text(
                text['heading'],
                style: appFonts.getTextStyle('faq_heading_style'),
              )),
              text['questionsAndAnswers'] != null &&
                      text['questionsAndAnswers'].length > 0
                  ? Container(
                      child: Column(
                          children: getFaqSubData(text['questionsAndAnswers'])))
                  : Container(),
              text['content'] != null
                  ? Container(
                      child: Text(text['content'],
                          textAlign: TextAlign.justify,
                          style: appFonts.getTextStyle('faq_content_style')),
                    )
                  : Container()
            ],
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldkey,
        appBar: appBarWidgetWithIconsAnSearchboxAndFilterIcon(
            context,
            true,
            this.setState,
            false,
            '/faqs',
            searchFieldKey,
            searchFieldController,
            searchFocusNode,
            scaffoldkey),
        endDrawer: showOrHideSearchAndFilter
            ? filterDrawer(this.setState, context, scaffoldkey, false,
                searchFieldController)
            : null,
        body: Container(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
                margin: EdgeInsets.only(right: 20, left: 20),
                child: Column(
                  children: getFaqData(),
                )),
          ),
        ));
  }
}
