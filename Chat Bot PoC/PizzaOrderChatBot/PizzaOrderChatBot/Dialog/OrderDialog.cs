using Microsoft.Bot.Builder.Dialogs;
using Microsoft.Bot.Builder.Luis;
using Microsoft.Bot.Builder.Luis.Models;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;

namespace PizzaOrderChatBot.Dialog
{
    [LuisModel("bab87589-9383-443b-b125-0c3fd9e9b33d", "30be4c69260d407aa3e6613919ee5e5a")]
    [Serializable]
    public class OrderDialog : LuisDialog<object>
    {
        private const string Product_Entity = "Product";

        private DialogPhase dialogPhase = DialogPhase.Start;

        private string[] mains;
        private string[] sides;
        private string[] drinks;

        [LuisIntent("")]
        public async Task None(IDialogContext context, LuisResult result)
        {
            await DidntGetThat(context);
        }

        private async Task DidntGetThat(IDialogContext context)
        {
            string message = Phrases.DIDNT_GET_THAT;

            Thread.Sleep(400);

            await context.PostAsync(message);
            context.Wait(MessageReceived);
        }

        [LuisIntent("Hello")]
        public async Task Hello(IDialogContext context, LuisResult result)
        {
            if (dialogPhase == DialogPhase.Start || dialogPhase == DialogPhase.Bye)
            {
                dialogPhase = DialogPhase.Start;

                Thread.Sleep(400);
                await context.PostAsync(Phrases.HELLO);

                Thread.Sleep(1000);
                await context.PostAsync(Phrases.MAIN_ORDER);
                context.Wait(MessageReceived);
            }
            else
            {
                await StartOverAction(context);
            }
        }

        [LuisIntent("StartOver")]
        public async Task StartOver(IDialogContext context, LuisResult result)
        {
            await StartOverAction(context);
        }

        private async Task StartOverAction(IDialogContext context)
        {
            ResetDialog();

            dialogPhase = DialogPhase.Start;
            Thread.Sleep(400);
            await context.PostAsync(Phrases.START_OVER);

            Thread.Sleep(1000);
            await context.PostAsync(Phrases.MAIN_ORDER);
            context.Wait(MessageReceived);
        }

        [LuisIntent("Bye")]
        public async Task Bye(IDialogContext context, LuisResult result)
        {
            if (dialogPhase != DialogPhase.Bye)
            {
                ResetDialog();
                Thread.Sleep(400);
                await context.PostAsync(Phrases.GOODBYE);
                context.Wait(MessageReceived);
            }
            else
            {
                context.Wait(MessageReceived);
            }
        }

        [LuisIntent("Order")]
        public async Task Order(IDialogContext context, LuisResult result)
        {
            var items = result.Entities.Where(e => e.Type == Product_Entity).Select(e => e.Entity).ToArray();

            SetOrders(items);
            await HandleOrder(context);
        }

        private void SetOrders(string[] items)
        {
            if (dialogPhase == DialogPhase.Start)
            {
                if (mains == null)
                {
                    mains = items;
                }
                else
                {
                    mains = mains.Concat(items).ToArray();
                }
            }
            else if (dialogPhase == DialogPhase.Main)
            {
                if (sides == null)
                {
                    sides = items;
                }
                else
                {
                    sides = sides.Concat(items).ToArray();
                }
            }
            else if (dialogPhase == DialogPhase.Sides)
            {
                if (drinks == null)
                {
                    drinks = items;
                }
                else
                {
                    drinks = drinks.Concat(items).ToArray();
                }
            }
        }

        private async Task HandleOrder(IDialogContext context)
        {
            var message = dialogPhase == DialogPhase.Start ? Phrases.SIDES_ORDER : (dialogPhase == DialogPhase.Main ? Phrases.DRINKS_ORDER : Phrases.ORDER_SUMMARY);

            dialogPhase = dialogPhase == DialogPhase.Start ? DialogPhase.Main : (dialogPhase == DialogPhase.Main ? DialogPhase.Sides : DialogPhase.Drink);

            Thread.Sleep(1000);
            await context.PostAsync(message);
            if (dialogPhase == DialogPhase.Drink)
            {
                Thread.Sleep(500);
                var orderMessage = "Main: " + (mains.Length == 0 ? "no main" : string.Join(",", mains)) + $"  {Environment.NewLine}"
                + "Sides: " + (sides.Length == 0 ? "no sides" : string.Join(",", sides)) + $"  {Environment.NewLine}"
                + "Drinks: " + (drinks.Length == 0 ? "no drinks" : string.Join(",", drinks));
                await context.PostAsync(orderMessage);

                Thread.Sleep(1000);
                await context.PostAsync(Phrases.ANYTHING_ELSE);
            }
            context.Wait(MessageReceived);
        }

        [LuisIntent("Yes")]
        public async Task Yes(IDialogContext context, LuisResult result)
        {
            if (dialogPhase == DialogPhase.Drink)
            {
                dialogPhase = DialogPhase.Start;
                Thread.Sleep(1000);
                await context.PostAsync(Phrases.MAIN_ORDER);
                context.Wait(MessageReceived);
            }
            else if (dialogPhase == DialogPhase.Bye)
            {
                await DidntGetThat(context);
                context.Wait(MessageReceived);
            }
            else
            {
                var items = result.Entities.Where(e => e.Type == Product_Entity).Select(e => e.Entity).ToArray();
                SetOrders(items);
                await HandleOrder(context);
            }
        }

        [LuisIntent("No")]
        public async Task No(IDialogContext context, LuisResult result)
        {
            if (dialogPhase == DialogPhase.Drink)
            {
                ResetDialog();
                Thread.Sleep(400);
                await context.PostAsync(Phrases.GOODBYE);
                context.Wait(MessageReceived);
            }
            else if (dialogPhase == DialogPhase.Bye)
            {
                await DidntGetThat(context);
                context.Wait(MessageReceived);
            }
            else
            {
                SetOrders(new string[] { });
                await HandleOrder(context);
            }
        }

        private void ResetDialog()
        {
            dialogPhase = DialogPhase.Bye;
            mains = null;
            sides = null;
            drinks = null;
        }
    }
}