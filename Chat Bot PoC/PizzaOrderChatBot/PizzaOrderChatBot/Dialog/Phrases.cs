using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PizzaOrderChatBot.Dialog
{
    public class Phrases
    {
        // Starting the conversation
        public const string HELLO = "Hello, good to talk to you. I hope you're well.\nI am your personal Pizza Order chat bot. How can I help you today?";
        public const string MAIN_ORDER = "Should we start with ordering the main course? Which pizza would you like?";
        public const string SIDES_ORDER = "Would you like any sides? Maybe a salad or chips?";
        public const string DRINKS_ORDER = "Something to drink? We have variety of soft drinks available to order.";

        public const string ORDER_SUMMARY = "Ok, I think I have everything. Here's your order summary.";
        public const string ANYTHING_ELSE = "The delivery should take around 40 mins. It will be sent to your delivery address.\nIs there anythin else I could help you with?";

        // Finishing the conversation
        public const string GOODBYE = "Goodbye. Have a great day!";

        public const string START_OVER = "I guess you want to start over. Let's try this again.";

        public const string DIDNT_GET_THAT = "Sorry, didn't get that! Could you rephrase.";
    }
}