using UnityEngine;

[ExecuteInEditMode]
public class BlackHole : MonoBehaviour
{
    public Transform hole_object;
    public float rad = 3f;
    public float black_rad_1 = 1f; // radius where black color starts
    public float black_rad_2 = 4f; // radius where black color starts blend with background
    public float ior = 0.38f;

    private Material _material;
    
    void OnEnable()
    {
        _material = new Material(Shader.Find("BlackHole"));
    }


    // Postprocess
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Vector2 screenPos; // position hole in screen coordinate [0,1]x[0,1]

        float distance;

        if (hole_object != null)
        {
            screenPos = new Vector2(
                GetComponent<Camera>().WorldToScreenPoint(hole_object.position).x / GetComponent<Camera>().pixelWidth,
                1 - GetComponent<Camera>().WorldToScreenPoint(hole_object.position).y / GetComponent<Camera>().pixelHeight);

            distance = Vector3.Distance(hole_object.transform.position, transform.position);
        }
        else
        {
            screenPos = new Vector2(0.5f, 0.5f);
            distance = 10.0f;
        }

        _material.SetFloat("_dist", distance);
        _material.SetVector("screenPos", screenPos);
        _material.SetFloat("IOR", ior);
        _material.SetFloat("black_r1", black_rad_1/distance);
        _material.SetFloat("black_r2", black_rad_2/distance);
        _material.SetFloat("rad", rad);

        Graphics.Blit(source, destination, _material);
    }
}
