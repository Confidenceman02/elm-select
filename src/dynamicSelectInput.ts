const noop = () => {};

export function dynamicSelectInput(el: HTMLElement, props: {}) {
  console.log("Hi from defo");
  return { destroy: noop, update: () => console.log("Hi from defo") };
}
