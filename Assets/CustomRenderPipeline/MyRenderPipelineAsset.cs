using UnityEngine;
using UnityEngine.Rendering;
[CreateAssetMenu(fileName = "NewMyRenderPipelineAsset",menuName = "MyRenderPipelineAsset",order =0)]
public class MyRenderPipelineAsset : RenderPipelineAsset
{
    protected override RenderPipeline CreatePipeline()
    {
        return new MyRenderPipeline();
    }


}
