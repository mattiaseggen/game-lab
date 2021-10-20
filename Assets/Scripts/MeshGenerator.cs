using UnityEngine;

public class MeshGenerator
{
    public float minHeight;
    public float maxHeight;
    public Color[] colorMap;

    public void GenerateMesh(float[,] noiseMap, Mesh mesh, int mapWidth, int mapHeight, float amplitude, Biome[] biomes)
    {
        mesh.name = "Mesh yo";

        Vector3[] vertices = new Vector3[(mapWidth + 1) * (mapHeight + 1)];
        Vector2[] uv = new Vector2[vertices.Length];

        for (int z = 0, i = 0; z <= mapHeight; z++)
        {
            for (int x = 0; x <= mapWidth; x++, i++)
            {
                float y = noiseMap[x, z] * amplitude;
                vertices[i] = new Vector3(x, y, z);
                uv[i] = new Vector2((float)x / mapWidth, (float)z / mapHeight);

                if (y < minHeight)
                {
                    minHeight = y;
                } else if (y > maxHeight)
                {
                    maxHeight = y;
                }
            }
        }
        mesh.vertices = vertices;
        mesh.uv = uv;

        colorMap = new Color[vertices.Length];
        for (int z = 0, i = 0; z <= mapHeight; z++)
        {
            for (int x = 0; x <= mapWidth; x++, i++)
            {
                float height = (vertices[i].y - minHeight) / (maxHeight - minHeight);
                for (int j = 0; j < biomes.Length; j++)
                {
                    if (height < biomes[j].height)
                    {
                        colorMap[z * mapWidth + x] = biomes[j].color;
                        break;
                    }
                }
            }
        }

        int[] tris = new int[mapWidth * mapHeight * 6];
        for (int ti = 0, vi = 0, z = 0; z < mapHeight; z++, vi++)
        {
            for (int x = 0; x < mapWidth; x++, ti += 6, vi++)
            {
                tris[ti] = vi;
                tris[ti + 3] = tris[ti + 2] = vi + 1;
                tris[ti + 4] = tris[ti + 1] = vi + mapWidth + 1;
                tris[ti + 5] = vi + mapWidth + 2;
            }
        }

        mesh.triangles = tris;
        mesh.RecalculateNormals();
    }
}