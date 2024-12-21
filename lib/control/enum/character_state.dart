enum CharacterAnimationState {
  beginIdle,
  idleDown,
  idleUp,
  idleLeft,
  idleRight,
  walkLeft,
  walkRight,
  walkUp,
  walkDown,
  attackDown,
  attackUp,
  attackLeft,
  attackRight,
  takingDamage;

  String toJson() => name;
  static CharacterAnimationState fromJson(String json) => values.byName(json);
}