/*
	アウトライン検出シェーダー by あるる（きのもと 結衣）
	Detect Outline Shader by KINOMOTO Yui @arlez80

	MIT License
*/

shader_type canvas_item;
render_mode unshaded, blend_disabled, skip_vertex_transform;

uniform float luma_coef = 1024.0;

void check_priority( inout float line_width, inout float line_priority, in vec3 c )
{
	if( line_priority < c.b ) {
		line_priority = c.b;
		line_width = c.g;
	}
}

void fragment( )
{
	/*
		入力：
			R: 物体ID
				ここが違うとアウトラインとして抽出される。なにもない所は0
			G: 線分の太さ
			B: 優先度
				高い方の線分太さが優先される
	*/

	vec3 color = texture( SCREEN_TEXTURE, SCREEN_UV ).rgb;

	//vec3 minus_x = texture( SCREEN_TEXTURE, SCREEN_UV + vec2( -1.0, 0.0 ) * SCREEN_PIXEL_SIZE ).rgb;
	vec3 plus_x = texture( SCREEN_TEXTURE, SCREEN_UV + vec2( 1.0, 0.0 ) * SCREEN_PIXEL_SIZE ).rgb;
	//vec3 minus_y = texture( SCREEN_TEXTURE, SCREEN_UV + vec2( 0.0, -1.0 ) * SCREEN_PIXEL_SIZE ).rgb;
	vec3 plus_y = texture( SCREEN_TEXTURE, SCREEN_UV + vec2( 0.0, 1.0 ) * SCREEN_PIXEL_SIZE ).rgb;
	//vec3 x = - minus_x + plus_x;
	//vec3 y = - minus_y + plus_y;
	vec3 x = - color + plus_x;
	vec3 y = - color + plus_y;
	vec3 filtered = sqrt( x * x + y * y );

	float line_width = color.g;
	float line_width_priority = color.b;
	//check_priority( line_width, line_width_priority, minus_x );
	check_priority( line_width, line_width_priority, plus_x );
	//check_priority( line_width, line_width_priority, minus_y );
	check_priority( line_width, line_width_priority, plus_y );

	/*
		出力：
			R: アウトライン検出
			G: 線分の太さ
			B: 優先度
			A: 未使用
	*/
	float use = float( 0.0 < line_width );
	COLOR = vec4( clamp( filtered.r * luma_coef, 0.0, 1.0 ) * use, line_width, line_width_priority, 1.0 );
}
