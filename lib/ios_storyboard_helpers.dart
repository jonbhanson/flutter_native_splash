part of 'ios.dart';

xml.XmlElement _findSingleElement(xml.XmlDocument document, String name) {
  final elements = document.findAllElements(name);
  if (elements.length > 1) {
    throw LaunchScreenStoryboardModified(
        "Multiple '$name' tags found in LaunchScreen.storyboard. Image for splash screen not updated. Did you modify your default LaunchScreen.storyboard file?");
  }
  if (elements.isEmpty) {
    throw LaunchScreenStoryboardModified(
        "No '$name' tag found in LaunchScreen.storyboard. Image for splash screen not updated. Did you modify your default LaunchScreen.storyboard file?");
  }
  return elements.first;
}

void _updateXmlElementAttribute(
    xml.XmlElement element, String name, String value) {
  final xmlName = xml.XmlName(name);
  element.attributes.removeWhere((element) => element.name == xmlName);

  element.attributes.add(xml.XmlAttribute(xml.XmlName(name), value));
}

void _removeConstraint(xml.XmlElement element, String id) {
  element.children.removeWhere((child) {
    final idAttribute = child.attributes.firstWhere(
        (attribute) => attribute.name == xml.XmlName('id'),
        orElse: () => null);
    return idAttribute?.value == id;
  });
}

void _addEqualityConstraint(xml.XmlElement constraintsElement,
    {String firstItem, String secondItem, String attribute, String id}) {
  final constraintElement = xml.XmlElement(xml.XmlName('constraint'));
  constraintElement.attributes.addAll([
    xml.XmlAttribute(xml.XmlName('firstItem'), firstItem),
    xml.XmlAttribute(xml.XmlName('firstAttribute'), attribute),
    xml.XmlAttribute(xml.XmlName('secondItem'), secondItem),
    xml.XmlAttribute(xml.XmlName('secondAttribute'), attribute),
    xml.XmlAttribute(xml.XmlName('id'), id),
  ]);
  constraintsElement.children.add(constraintElement);
}

void _updateEqualityConstraint(xml.XmlElement constraintsElement,
    {String firstItem, String secondItem, String attribute, String id}) {
  _removeConstraint(constraintsElement, id);
  _addEqualityConstraint(constraintsElement,
      firstItem: firstItem,
      secondItem: secondItem,
      attribute: attribute,
      id: id);
}
