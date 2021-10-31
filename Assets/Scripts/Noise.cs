using UnityEngine;

public static class Noise
{
    public static float[,] GenerateNoiseMap(int mapWidth, int mapHeight, float scale, int octaves, float exp, float xOffset, float yOffset)
    {

        if (scale <= 0)
        {
            scale = 0.0001f;
        }

        float[,] noiseMap = new float[mapWidth + 1, mapHeight + 1];
        for (int y = 0; y <= mapHeight; y++)
        {
            for (int x = 0; x <= mapWidth; x++)
            {
                float nx = x / scale + xOffset;
                float ny = y / scale + yOffset;
                float e = 0;
                float amplitude = 0;

                // For each octave the frequency increases by a factor of 2^i, and
                // the amplitude is multiplied with a factor of 1/(2^i).
                // This results in different overlapping noise maps of higher frequency.

                for (int i = 0; i < octaves; i++)
                {
                    float freq = Mathf.Pow(2, i);
                    amplitude += 1 / (Mathf.Pow(2, i));
                    e += (1 / (Mathf.Pow(2, i))) * Mathf.PerlinNoise(freq * nx, freq * ny);

                }

                e = e / amplitude;
                noiseMap[x, y] = Mathf.Pow(e, exp);
                //Debug.Log("noiseMap[" + x + ", " + y + "]: " + noiseMap[x, y]);
            }
        }

        return noiseMap;
    }
}
