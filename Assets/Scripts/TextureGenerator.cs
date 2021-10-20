using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class TextureGenerator
{
    public static Texture2D GenerateTexture(Color[] colorMap, int mapWidth, int mapHeight)
    {
        Texture2D texture = new Texture2D(mapWidth, mapHeight);
        texture.SetPixels(colorMap);
        texture.Apply();
        return texture;
    }
}
