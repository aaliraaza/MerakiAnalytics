using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApplication1
{
    public class Sensor
    {

        public Guid newGuid = new Guid();
        public string time;
        public string dspl;
        public int temp;
        public int hmdt;
        public string secret;
        static Random R = new Random();
        static string[] sensorNames = new[] { "sensorA", "sensorB", "sensorC", "sensorD", "sensorE" };

        public static Sensor Generate()
        {
            return new Sensor { newGuid = Guid.NewGuid(), secret = "MerakiPOC", time = DateTime.UtcNow.ToString(), dspl = sensorNames[R.Next(sensorNames.Length)], temp = R.Next(70, 150), hmdt = R.Next(30, 70) };
        }
    }
}
