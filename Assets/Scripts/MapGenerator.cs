using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class MapGenerator : MonoBehaviour
{
    public int mapWidth;
    public int mapHeight;
    public float scale;
    [Range(1, 10)]
    public int octaves;
    public float amplitude;
    [Range(0, 10)]
    public float redistribution = 1;

    [Range(0, 1)]
    public float water;

    public Biome[] biomes;

    public bool autoUpdate;

    public void GenerateMap()
    {
        float[,] noiseMap = Noise.GenerateNoiseMap(mapWidth, mapHeight, scale, octaves, redistribution);

        Mesh mesh = GetComponent<MeshFilter>().sharedMesh;
        MeshGenerator meshGenerator = new MeshGenerator();
        meshGenerator.GenerateMesh(noiseMap, mesh, mapWidth, mapHeight, amplitude, biomes);

        Color[] colorMap = meshGenerator.colorMap;
        Texture2D texture = TextureGenerator.GenerateTexture(colorMap, mapWidth, mapHeight);
        Renderer rend = GetComponent<MeshRenderer>();
        rend.sharedMaterial.mainTexture = texture;

        //if (!rend.sharedMaterial)
        //{
        //    rend.sharedMaterial = new Material(Shader.Find("Custom/ColorShader"));
        //}
    //    rend.sharedMaterial.SetFloat("_MinHeight", meshGenerator.minHeight);
    //    rend.sharedMaterial.SetFloat("_MaxHeight", meshGenerator.maxHeight);
    }

    public void OnValidate()
    {
        if (mapWidth < 1) { mapWidth = 1; }
        if (mapHeight < 01) { mapHeight = 1; }
        if (scale <= 0) { scale = 0.0001f; }
    }

}

[System.Serializable]
public struct Biome {
    public string name;
    public Color color;
    [Range(0,1)]
    public float height;
};