#version 330 core
struct Material {
	sampler2D diffuse;
	sampler2D specular;
	sampler2D emission;
    float shininess;
}; 

struct Light {
   	vec3 position; // 使用定向光就不再需要了
   	//vec3 direction;
	
	float constant;
    float linear;
    float quadratic;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};
out vec4 FragColor;

uniform vec3 viewPos;
uniform Material material;
uniform Light light;

in vec2 TexCoords;
in vec3 FragPos;  
in vec3 Normal;
in vec3 lightDir;

void main()
{
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));
    
    vec3 norm = normalize(Normal);
	//vec3 lightDir = normalize(-light.direction);
	vec3 lightDir = normalize(light.position - FragPos);
	
	float diff = max(dot(norm, lightDir), 0.0);
	vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));
	
	vec3 viewDir = normalize(viewPos - FragPos);
	vec3 reflectDir = reflect(-lightDir, norm);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
	vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
	//vec3 specular = light.specular * spec * (vec3(1.0) - vec3(texture(material.specular, TexCoords)));
	
	// emission
    vec3 emission = texture(material.emission, TexCoords).rgb;
        
    float distance    = length(light.position - FragPos);
	float attenuation = 1.0 / (light.constant + light.linear * distance + 
                	light.quadratic * (distance * distance));

	ambient  *= attenuation; 
	diffuse  *= attenuation;
	specular *= attenuation;
                
    vec3 result = ambient + diffuse + specular + emission;
	FragColor = vec4(result, 1.0);
}